//
//  MeditationInterfaceController.swift
//  InsideWatch Extension
//
//  Created by Bianca Itiroko on 22/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class MeditationInterfaceController: WKInterfaceController {

    @IBOutlet private weak var startStopButton : WKInterfaceButton!

    @IBOutlet var timer: WKInterfaceTimer!
    
    let MY_LEVEL = 2
    
    var internalTimer: Timer?
    
    var initialHeartRate = 0.0
    var lowestHeartRate = 0.0
    
    let healthStore = HKHealthStore()
    
    //State of the app - is the workout activated
    var workoutActive = false
    
    // define the activity type and location
    var session : HKWorkoutSession?
    let heartRateUnit = HKUnit(from: "count/min")
    //var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    var currenQuery : HKQuery?
    
    let userDefaults = UserDefaults.standard
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.userDefaults.set(false, forKey: "wonBackgroundLevel")
    }
    
    override func willActivate() {
        super.willActivate()
        
        // Request HealthKit authorization
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            guard authorized else {

                let baseMessage = "HealthKit Authorization Failed"

                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                return
            }
            print("HealthKit Successfully Authorized.")
        }
    }
    
    override func willDisappear() {
        super.willDisappear()
        // finishes workout whenever view will disappear
        self.finishCurrentWorkout()
    }
    
    // When Start/Stop button is pressed
    @IBAction func startBtnTapped() {
        if (self.workoutActive) {
            //finish the current workout
            self.finishCurrentWorkout()
        } else {
            //start a new workout
            self.workoutActive = true
            self.startStopButton.setTitle("Stop")
            
            self.setTimer()
            self.startWorkout()
        }
    }
    
    @objc func finishCurrentWorkout() {
        self.timer.stop()
        self.workoutActive = false
        self.internalTimer?.invalidate()
        self.startStopButton.setTitle("Start")
        if let workout = self.session {
            healthStore.end(workout)
        }
    }
    
    
    // Set timer to meditate
    func setTimer() {
        let countdown: TimeInterval = 600
        let date = Date(timeIntervalSinceNow: countdown)
        self.internalTimer?.invalidate()
        self.internalTimer = Timer.scheduledTimer(timeInterval: countdown, target: self, selector: #selector(self.finishCurrentWorkout), userInfo: nil, repeats: false)
        self.timer.setDate(date)
        self.timer.start()
    }
    
    func updateHeartRate(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        DispatchQueue.main.async {
            guard let sample = heartRateSamples.first else{return}
            let value = sample.quantity.doubleValue(for: self.heartRateUnit)
            if self.lowestHeartRate > value || self.lowestHeartRate == 0.0 {
                self.lowestHeartRate = value
            }
            if self.initialHeartRate == 0.0 {  // set initial heart rate
                self.initialHeartRate = value
            }
        }
    }
}

extension MeditationInterfaceController: HKWorkoutSessionDelegate {
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            workoutDidStart(date)
        case .ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Do nothing for now
        print("Workout error")
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    func startWorkout() {
        
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .crossTraining
        workoutConfiguration.locationType = .indoor
        
        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
            session?.delegate = self
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        healthStore.start(self.session!)
    }
    
    func workoutDidStart(_ date : Date) {
        if let query = createHeartRateStreamingQuery(date) {
            self.currenQuery = query
            healthStore.execute(query)
        }
    }
    
    func workoutDidEnd(_ date : Date) {
        healthStore.stop(self.currenQuery!)
        initialHeartRate = 0.0
        session = nil
    }
}

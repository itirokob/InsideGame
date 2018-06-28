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
import WatchConnectivity

class MeditationInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet private weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet private weak var deviceLabel : WKInterfaceLabel!
    @IBOutlet private weak var heart: WKInterfaceImage!
    @IBOutlet private weak var startStopButton : WKInterfaceButton!

    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var goalCompleted: WKInterfaceLabel!
    
    let MY_LEVEL = 2
    
    var internalTimer: Timer?
    
    var initialHeartRate = 0.0
    var lowestHeartRate = 0.0

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    let healthStore = HKHealthStore()
    
    //State of the app - is the workout activated
    var workoutActive = false
    
    // define the activity type and location
    var session : HKWorkoutSession?
    let heartRateUnit = HKUnit(from: "count/min")
    //var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    var currenQuery : HKQuery?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let message = message["shouldDismiss"] as? Bool{
            if message {
                self.dismiss()
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        // Request HealthKit authorization
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            guard authorized else {

                let baseMessage = "HealthKit Authorization Failed"
                self.displayNotAllowed()

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
    
    func displayNotAllowed() {
        heartRateLabel.setText("Healthkit not available.")
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
        self.displayHRValues()
    }
    
    func displayHRValues() {
        self.goalCompleted.setText("i: \(self.initialHeartRate)  l: \(self.lowestHeartRate)")
    }
    
    
    
    // Set timer to meditate
    func setTimer() {
        let countdown: TimeInterval = 10
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
            
            self.heartRateLabel.setText(String(UInt16(value)))
            
            // retrieve source from sample
            let name = sample.sourceRevision.source.name
            self.updateDeviceName(name)
            self.animateHeart()
        }
    }
    
    func updateDeviceName(_ deviceName: String) {
        deviceLabel.setText(deviceName)
    }
    
    func animateHeart() {
        self.animate(withDuration: 0.5) {
            self.heart.setWidth(60)
            self.heart.setHeight(90)
        }
        
        let when = DispatchTime.now() + Double(Int64(0.5 * double_t(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.animate(withDuration: 0.5, animations: {
                    self.heart.setWidth(50)
                    self.heart.setHeight(80)
                })
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
            //self.anchor = newAnchor!
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
        } else {
            heartRateLabel.setText("cannot start")
        }
    }
    
    func workoutDidEnd(_ date : Date) {
        healthStore.stop(self.currenQuery!)
        initialHeartRate = 0.0
        heartRateLabel.setText("---")
        session = nil
    }
}

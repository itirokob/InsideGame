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

    @IBOutlet private weak var heartRateLabel: WKInterfaceLabel!
    @IBOutlet private weak var heart: WKInterfaceImage!
    @IBOutlet private weak var startStopButton : WKInterfaceButton!

    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var goalCompleted: WKInterfaceLabel!
    
    let MY_LEVEL = 2
    
    var internalTimer: Timer?
    var initialHeartRate = 0.0
    var lowestHeartRate = 0.0
    
    //State of the app - is the workout activated
    var workoutActive = false
    
    var workoutSession: WorkoutSessionService?
    
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
            self.startNewWorkout()
        }
    }
    
    func startNewWorkout() {
        self.workoutActive = true
        self.startStopButton.setTitle("Stop")
        self.setTimer()
        self.workoutSession = WorkoutSessionService(exerciseType: ExerciseType.running)
        if workoutSession != nil {
            workoutSession!.delegate = self
            workoutSession!.startSession()
        }
    }
    
    @objc func finishCurrentWorkout() {
        self.timer.stop()
        self.workoutActive = false
        self.internalTimer?.invalidate()
        self.startStopButton.setTitle("Start")
        self.workoutSession?.stopSession()
        self.displayHRValues()
    }
    
    func displayHRValues() {
        self.goalCompleted.setText("i: \(self.initialHeartRate)  l: \(self.lowestHeartRate)")
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
    
    func updateHeartRate(heartRate: Double) {
        DispatchQueue.main.async {
            if self.lowestHeartRate > heartRate || self.lowestHeartRate == 0.0 {
                self.lowestHeartRate = heartRate
            }
            if self.initialHeartRate == 0.0 {  // set initial heart rate
                self.initialHeartRate = heartRate
            }
            
            self.heartRateLabel.setText(String(UInt16(heartRate)))
            
            // retrieve source from sample
            self.animateHeart()
        }
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
    
    func workoutDidEnd(_ date : Date) {
        self.initialHeartRate = 0.0
        self.heartRateLabel.setText("---")
    }
}

extension MeditationInterfaceController: WorkoutSessionServiceDelegate {
    
    func workoutSessionService(_ service: WorkoutSessionService, didStartWorkoutAtDate startDate: Date) {
    }
    
    func workoutSessionService(_ service: WorkoutSessionService, didStopWorkoutAtDate endDate: Date) {
        self.workoutDidEnd(endDate)
    }
    
    func workoutSessionServiceDidSave(_ service: WorkoutSessionService) {
        self.dismiss()
    }
    
    func workoutSessionService(_ service: WorkoutSessionService, didUpdateHeartrate heartRate:Double) {
        self.updateHeartRate(heartRate: heartRate)
    }
    
}

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
    
    
    /// When Start/Stop button is pressed, finishes or starts a new workout
    @IBAction func startBtnTapped() {
        if (self.workoutActive) {
            //finish the current workout
            self.finishCurrentWorkout()
        } else {
            //start a new workout
            self.startNewWorkout()
        }
    }
    
    /// Starts a workout session and starts the timer
    func startNewWorkout() {
        self.workoutActive = true
        self.setTimer()
        self.workoutSession = WorkoutSessionService(exerciseType: ExerciseType.running)
        if workoutSession != nil {
            workoutSession!.delegate = self
            workoutSession!.startSession()
        }
    }
    
    /// Finishes workout and stops the timer
    @objc func finishCurrentWorkout() {
        self.timer.stop()
        self.workoutActive = false
        self.internalTimer?.invalidate()
        self.workoutSession?.stopSession()
    }
    
    /// Sets timer to meditate and sets an internal timer to finish the workout when times up
    func setTimer() {
        let countdown: TimeInterval = 600
        let date = Date(timeIntervalSinceNow: countdown)
        self.internalTimer?.invalidate()
        self.internalTimer = Timer.scheduledTimer(timeInterval: countdown, target: self, selector: #selector(self.finishCurrentWorkout), userInfo: nil, repeats: false)
        self.timer.setDate(date)
        self.timer.start()
    }
    
    
    /// updates the lowest and initial heart rates
    ///
    /// - Parameter heartRate: double value of the heart rate
    func updateHeartRate(heartRate: Double) {
        DispatchQueue.main.async {
            if self.lowestHeartRate > heartRate || self.lowestHeartRate == 0.0 {
                self.lowestHeartRate = heartRate
            }
            if self.initialHeartRate == 0.0 {  // set initial heart rate
                self.initialHeartRate = heartRate
            }
        }
    }
    
    
    /// Resets the initial heart rate value to 0.0
    ///
    /// - Parameter date: date in which the workout started
    func workoutDidEnd(_ date : Date) {
        self.initialHeartRate = 0.0
        if (initialHeartRate - lowestHeartRate >= 0.1*initialHeartRate) {
            self.wonLevel(level: MY_LEVEL)
        }
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

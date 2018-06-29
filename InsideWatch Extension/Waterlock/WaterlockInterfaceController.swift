//
//  WaterlockInterfaceController.swift
//  InsideWatch Extension
//
//  Created by Bianca Itiroko on 27/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class WaterlockInterfaceController: WKInterfaceController {

    let healthStore = HKHealthStore()
    let MY_LEVEL = 4

    var workoutSession:WorkoutSessionService?
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet var wavesImage: WKInterfaceImage!
    @IBOutlet var errorLabel: WKInterfaceLabel!
    @IBOutlet var finishLevelButton: WKInterfaceButton!
    
    /// To enable waterlock, a workout must be running. Only in first time this controller is launched, we'll set it with a swimming workout.
    override func awake(withContext context: Any?) {
        self.errorLabel.setHidden(true)
        super.awake(withContext: context)
        self.userDefaults.set(false, forKey: "wonBackgroundLevel")
        
        self.workoutSession = WorkoutSessionService(exerciseType: ExerciseType.swimming)
        
        // If workout session is nil, then it means that the swimming workout could not be initiated, which means that the device does not support waterlock (only available for series 2 and 3.
        if workoutSession != nil {
            workoutSession!.delegate = self
            workoutSession!.startSession()
        } else {
            self.errorLabel.setHidden(false)
            self.finishLevelButton.setHidden(true)
            self.wavesImage.setHidden(true)
            self.errorLabel.setText("Your device does not support this level.")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func finishedLevelAction() {
        workoutSession?.stopSession()
        self.wonLevel(level: MY_LEVEL)
    }
}

extension WaterlockInterfaceController: WorkoutSessionServiceDelegate {
    
    func workoutSessionService(_ service: WorkoutSessionService, didStopWorkoutAtDate endDate: Date) {
    }
    
    func workoutSessionServiceDidSave(_ service: WorkoutSessionService) {
        self.dismiss()
    }
    
    func workoutSessionService(_ service: WorkoutSessionService, didUpdateHeartrate heartRate:Double) {
    }
    
}


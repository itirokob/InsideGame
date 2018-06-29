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
    var workoutSession:WorkoutSessionService?

    let userDefaults = UserDefaults.standard

    @IBOutlet var stopButton: WKInterfaceButton!
    
    @IBAction func stopButtonPressed() {
        workoutSession?.stopSession()
    }
    
    /// To enable waterlock, a workout must be running. Only in first time this controller is launched, we'll set it with a swimming workout.
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.userDefaults.set(false, forKey: "wonBackgroundLevel")

        self.workoutSession = WorkoutSessionService(exerciseType: ExerciseType.swimming)
        
        if workoutSession != nil {
            stopButton.setTitle("FUNCIONA")
            workoutSession!.delegate = self
            workoutSession!.startSession()
        }

//        let workoutConfig = HKWorkoutConfiguration()
//        workoutConfig.activityType = .swimming
//        workoutConfig.swimmingLocationType = .pool
//        workoutConfig.lapLength = HKQuantity(unit: HKUnit.meter(), doubleValue: 25.0)
//
//        do {
//            workoutSession = try HKWorkoutSession(configuration: workoutConfig)
//            workoutSession?.delegate = self
//
//            healthStore.start(workoutSession!)
//        } catch let error as NSError{
//            fatalError("Unable to create workout session! \(error.localizedDescription)")
//        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension WaterlockInterfaceController: WorkoutSessionServiceDelegate {
    func workoutSessionService(_ service: WorkoutSessionService, didStartWorkoutAtDate startDate: Date) {
    }

    func workoutSessionService(_ service: WorkoutSessionService, didStopWorkoutAtDate endDate: Date) {
    }

    func workoutSessionServiceDidSave(_ service: WorkoutSessionService) {
        self.dismiss()
    }

    func workoutSessionService(_ service: WorkoutSessionService, didUpdateHeartrate heartRate:Double) {
    }

}

//extension WaterlockInterfaceController:HKWorkoutSessionDelegate{
//    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
//        switch toState{
//        case .running:
//            let extensionObject = WKExtension.shared()
//            extensionObject.enableWaterLock()
//        default:
//            print("bla")
//        }
//    }
//
//    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
//        print(error.localizedDescription)
//    }


//}

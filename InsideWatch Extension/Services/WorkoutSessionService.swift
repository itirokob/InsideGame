//
//  WorkoutSessionService.swift
//  InsideWatch Extension
//
//  Created by Seong Eun Kim on 28/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit

protocol WorkoutSessionServiceDelegate: class {
    
    // This method is called when an HKWorkoutSession is correctly stopped
    func workoutSessionService(_ service: WorkoutSessionService, didStopWorkoutAtDate endDate: Date)
    
    // This method is called when a workout is successfully saved
    func workoutSessionServiceDidSave(_ service: WorkoutSessionService)
    
    // This method is called when an anchored query receives new heart rate data
    func workoutSessionService(_ service: WorkoutSessionService, didUpdateHeartrate heartRate:Double)

}

class WorkoutSessionService: NSObject {
    fileprivate let healthService = HealthKitSetupAssistant()
    let session: HKWorkoutSession
    
    var startDate: Date?
    var endDate: Date?
    
    var exerciseType: ExerciseType
    
    // ****** Stored Samples and Queries
    var hrData: [HKQuantitySample] = [HKQuantitySample]()
    
    // ****** Query Management
    fileprivate var hrQuery: HKQuery?
    internal var hrAnchorValue:HKQueryAnchor?
    
    weak var delegate:WorkoutSessionServiceDelegate?
    
    // ****** Current Workout Values
    var heartRate: HKQuantity

    // Creates a workout session according to the exercise that was sent as parameter
    init?(exerciseType: ExerciseType) {
        self.exerciseType = exerciseType
        let hkWorkoutConfiguration = HKWorkoutConfiguration()
        hkWorkoutConfiguration.activityType = exerciseType.activityType
        hkWorkoutConfiguration.locationType = exerciseType.location
        if(exerciseType.activityType == .swimming){
            hkWorkoutConfiguration.swimmingLocationType = HKWorkoutSwimmingLocationType.pool
            hkWorkoutConfiguration.lapLength = HKQuantity(unit: HKUnit.meter(), doubleValue: 25.0)
        }

        do {
            session = try HKWorkoutSession(configuration: hkWorkoutConfiguration)
        } catch {
            return nil
        }
        
        // Initialize Current Workout Values
        heartRate = HKQuantity(unit: hrUnit, doubleValue: 0.0)
        super.init()
        session.delegate = self
    }
    
    /// Starts health store session
    func startSession() {
        healthService.healthKitStore.start(session)
    }
    
    /// Ends heart store session
    func stopSession() {
        healthService.healthKitStore.end(session)
    }
}

extension WorkoutSessionService: HKWorkoutSessionDelegate {
    
    /// Does activity whenever state of the workout session changes
    ///
    /// - Parameters:
    ///   - workoutSession: workout session
    ///   - toState: value of the new state
    ///   - fromState: value of old state
    ///   - date: current date
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        
        DispatchQueue.main.async {
            switch toState {
            case .running:
                if (self.exerciseType.activityType == .running) {
                    self.sessionStarted(date)
                } else {
                    let extensionObject = WKExtension.shared()
                    extensionObject.enableWaterLock()
                }
                // Let the delegate know
                //self.delegate?.workoutSessionService(self, didStartWorkoutAtDate: date)
                break
            case .ended:
                if (self.exerciseType.activityType == .running) {
                    self.sessionEnded(date)
                }
                // Let the delegate know
                self.delegate?.workoutSessionService(self, didStopWorkoutAtDate: date)
                break
            default:
                print("Something weird happened. Not a valid state")
                break
            }
        }
    }
    
    // We used .running as the activityType as the workout for the meditation level. So if there is an error in the workout session, it stops the query
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didFailWithError error: Error) {
        if (self.exerciseType.activityType == .running) {
            sessionEnded(Date())
        }
    }
    

    /// When a workout event is created, we start a session on health store.
    ///
    /// - Parameters:
    ///   - workoutSession: workout session that was created
    ///   - event: workout event with its current state
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        switch event.type {
        case .pauseOrResumeRequest:
            switch workoutSession.state {
            case .running:
                self.stopSession()
            case .notStarted:
                self.startSession()
            default: break
            }
            break
        default:
            break
        }
    }
    
    /// When session starts, creates query to get heart rates
    ///
    /// - Parameter date: date in which session was started
    fileprivate func sessionStarted(_ date: Date) {
        // Create and start heart rate query
        hrQuery = heartRateQuery(withStartDate: date)
        healthService.healthKitStore.execute(hrQuery!)
        startDate = date
    }
    
    /// When the running session ends, we stop the query for the heart rates
    ///
    /// - Parameter date: date in which session was ended.
    fileprivate func sessionEnded(_ date: Date) {
        // Stop Any Queries
        healthService.healthKitStore.stop(hrQuery!)
        hrQuery = nil
        endDate = date
    }
    
    /// Creates a query for the heart rates
    ///
    /// - Parameter start: date of when we want the beginning of the hr data
    /// - Returns: the query that was created
    internal func heartRateQuery(withStartDate start: Date) -> HKQuery? {
        // Query all HR samples from the beginning of the workout session on the current device
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePredicate = HKQuery.predicateForSamples(withStart: start, end: nil, options: .strictEndDate )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        let query:HKAnchoredObjectQuery = HKAnchoredObjectQuery(type: quantityType,
                                                                predicate: predicate,
                                                                anchor: hrAnchorValue,
                                                                limit: Int(HKObjectQueryNoLimit)) {
                                                                    (query, sampleObjects, deletedObjects, newAnchor, error) in
                                                                    
                                                                    self.hrAnchorValue = newAnchor
                                                                    self.newHRSamples(sampleObjects)
        }
        
        query.updateHandler = {(query, samples, deleteObjects, newAnchor, error) in
            self.hrAnchorValue = newAnchor
            self.newHRSamples(samples)
        }
        
        return query
    }
    
    /// Selects samples and gets double value
    ///
    /// - Parameter samples: heart rate samples
    fileprivate func newHRSamples(_ samples: [HKSample]?) {
        // Abort if the data isn't right
        guard let samples = samples as? [HKQuantitySample], samples.count > 0 else {
            return
        }
        
        DispatchQueue.main.async {
            self.hrData += samples
            if let hr = samples.last?.quantity {
                self.heartRate = hr
                self.delegate?.workoutSessionService(self, didUpdateHeartrate: hr.doubleValue(for: hrUnit))
            }
        }
    }
}

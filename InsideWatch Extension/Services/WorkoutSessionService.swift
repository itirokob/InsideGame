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
    // This method is called when an HKWorkoutSession is correctly started
    func workoutSessionService(_ service: WorkoutSessionService, didStartWorkoutAtDate startDate: Date)
    
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
    
    init?(exerciseType: ExerciseType) {
        self.exerciseType = exerciseType
        
        let hkWorkoutConfiguration = HKWorkoutConfiguration()
        hkWorkoutConfiguration.activityType = exerciseType.activityType
        hkWorkoutConfiguration.locationType = exerciseType.location
        
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
    
    func startSession() {
        healthService.healthKitStore.start(session)
    }
    
    func stopSession() {
        healthService.healthKitStore.end(session)
    }
    
}

extension WorkoutSessionService: HKWorkoutSessionDelegate {
    
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
                
                
            case .ended:
                self.sessionEnded(date)
                
                
            default:
                print("Something weird happened. Not a valid state")
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didFailWithError error: Error) {
        sessionEnded(Date())
    }
    
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
    
    // MARK: Internal Session Control
    fileprivate func sessionStarted(_ date: Date) {
        
        // Create and start heart rate query
        hrQuery = heartRateQuery(withStartDate: date)
        
        healthService.healthKitStore.execute(hrQuery!)
        
        startDate = date
        
        // Let the delegate know
        delegate?.workoutSessionService(self, didStartWorkoutAtDate: date)
    }
    
    fileprivate func sessionEnded(_ date: Date) {
        
        // Stop Any Queries]
        healthService.healthKitStore.stop(hrQuery!)
        
        hrQuery = nil
        
        endDate = date
        
        // Let the delegate know
        delegate?.workoutSessionService(self, didStopWorkoutAtDate: date)
    }
    
    internal func heartRateQuery(withStartDate start: Date) -> HKQuery {
        // Query all HR samples from the beginning of the workout session on the current device
        let datePredicate = HKQuery.predicateForSamples(withStart: start, end: nil, options: .strictEndDate )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        let query:HKAnchoredObjectQuery = HKAnchoredObjectQuery(type: hrType,
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

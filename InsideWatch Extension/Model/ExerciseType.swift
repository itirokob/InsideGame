//
//  ExerciseType.swift
//  InsideWatch Extension
//
//  Created by Seong Eun Kim on 28/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import Foundation
import HealthKit

// Enum that contains exercise types and its info
enum ExerciseType: Int {
    case cycling = 1
    case stationaryBike
    case elliptical
    case functionalStrengthTraining
    case rowing
    case rowingMachine
    case running
    case treadmill
    case stairClimbing
    case swimming
    case stretching
    case walking
    case wheelchairRun
    case wheelchairWalk
    case other
    
    static let allValues = [cycling, stationaryBike, elliptical, functionalStrengthTraining, rowing, rowingMachine, running, treadmill, stairClimbing, swimming, stretching, walking, wheelchairRun, wheelchairWalk, other]
    
    
    var activityType: HKWorkoutActivityType {
        switch self {
        case .cycling:                    return .cycling
        case .stationaryBike:             return .cycling
        case .elliptical:                 return .elliptical
        case .functionalStrengthTraining: return .functionalStrengthTraining
        case .rowing:                     return .rowing
        case .rowingMachine:              return .rowing
        case .running:                    return .running
        case .treadmill:                  return .running
        case .stairClimbing:              return .stairClimbing
        case .swimming:                   return .swimming
        case .stretching:                 return .flexibility
        case .walking:                    return .walking
        case .wheelchairWalk:             return .wheelchairWalkPace
        case .wheelchairRun:              return .wheelchairRunPace
        case .other:                      return .other
        }
    }
    
    var location: HKWorkoutSessionLocationType {
        switch self {
        case .cycling:                    return .outdoor
        case .stationaryBike:             return .indoor
        case .elliptical:                 return .indoor
        case .functionalStrengthTraining: return .indoor
        case .rowing:                     return .outdoor
        case .rowingMachine:              return .indoor
        case .running:                    return .outdoor
        case .treadmill:                  return .indoor
        case .stairClimbing:              return .indoor
        case .swimming:                   return .indoor
        case .stretching:                 return .unknown
        case .walking:                    return .outdoor
        case .wheelchairWalk:             return .outdoor
        case .wheelchairRun:              return .outdoor
        case .other:                      return .unknown
        }
    }
    
    var locationName: String {
        switch self.location {
        case .indoor:  return "Indoor Exercise"
        case .outdoor: return "Outdoor Exercise"
        case .unknown: return "General Exercise"
        }
    }
    
    var hkWorkoutConfiguration: HKWorkoutConfiguration {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = self.activityType
        configuration.locationType = self.location
        return configuration
    }
}

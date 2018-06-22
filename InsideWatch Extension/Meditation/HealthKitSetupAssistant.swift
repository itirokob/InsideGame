//
//  HealthKitSetupAssistant.swift
//  InsideWatch Extension
//
//  Created by Bianca Itiroko on 22/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        
        // Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        // Prepares the types of data that will be read
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        
        // Request Authorization
        HKHealthStore().requestAuthorization(toShare: nil,
                                             read: dataTypes) { (success, error) in
                                                completion(success, error)
        }
    }
}

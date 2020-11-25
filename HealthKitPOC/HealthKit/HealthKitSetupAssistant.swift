//
//  HealthKitSetupAssistant.swift
//  HealthKitPOC
//
//  Created by Matheus Oliveira on 04/11/20.
//

import HealthKit

class HealthKitSetupAssistant {
    
    private enum HealthKitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
          completion(false, HealthKitSetupError.notAvailableOnDevice)
          return
        }
        
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
              let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
              let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
              let height = HKObjectType.quantityType(forIdentifier: .height),
              let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
              let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
                
                completion(false, HealthKitSetupError.dataTypeNotAvailable)
                return
        }
        
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        stepCount]
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                      bloodType,
                                                      biologicalSex,
                                                      bodyMassIndex,
                                                      height,
                                                      bodyMass,
                                                      stepCount,
                                                      sleepAnalysis]
        
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
          completion(success, error)
        }
    }
    
}

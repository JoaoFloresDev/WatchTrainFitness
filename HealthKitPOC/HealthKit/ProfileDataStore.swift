//
//  ProfileDataStore.swift
//  HealthKitPOC
//
//  Created by Matheus Oliveira on 04/11/20.
//

import HealthKit

class ProfileDataStore {
    
    /// Retrieve user blood type from HealthKit.
    /// - Returns: User unwrapped blood type. Ex: O+
    class func getBloodType() throws -> HKBloodType {
        let healthKitStore = HKHealthStore()
        
        do {
            let bloodType = try healthKitStore.bloodType()
            let unwrappedBlodType = bloodType.bloodType
            return unwrappedBlodType
        }
    }
    
    /// Retrieve user birthday information from HealthKit
    /// and calculates his/her age.
    /// - Returns: User age.
    class func getAge() throws -> Int {
        let healthKitStore = HKHealthStore()
        
        do {
            let birthdayComponents = try healthKitStore.dateOfBirthComponents()
            let today = Date()
            let calendar = Calendar.current
            let todayDateComponents = calendar.dateComponents([.year],
                                                                from: today)
            guard let thisYear = todayDateComponents.year,
                  let birthdayYear = birthdayComponents.year else {
                return 0
            }
            
            let age = thisYear - birthdayYear
            return age
        }
    }
    
    /// Retrieve user biological sex from HealthKit.
    /// - Returns: User unwrapped biological sex. Ex: Masculino.
    class func getBiologicalSex() throws -> HKBiologicalSex {
        let healthKitStore = HKHealthStore()
        
        do {
            let biologicalSex = try healthKitStore.biologicalSex()
            let unwrappedBiologicalSex = biologicalSex.biologicalSex
            return unwrappedBiologicalSex
        }
    }
    
    /// Query the lastest information of a given sample type
    /// Limited by a single information.
    class func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?,
                                                          Error?) -> Swift.Void) {
      
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            

            DispatchQueue.main.async {
                    
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                        completion(nil, error)
                        return
                }
                
                completion(mostRecentSample, nil)
            }
        }
         
        HKHealthStore().execute(sampleQuery)
    }
    
    /// Query informations from a day before of a given sample type
    /// Limited by 30 informations.
    class func getDayBeforeSample(for sampleType: HKSampleType,
                                           completion: @escaping ([HKSample]?,
                                                          Error?) -> Swift.Void) {
        
        //   Get the start of the day
        let date = Date()
        let newDate = date.dayBefore
      
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: newDate,
                                                              end: date,
                                                              options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit: Int = 30
                
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            DispatchQueue.main.async {
                    
                guard let samples = samples else {
                        completion(nil, error)
                        return
                }
                
                completion(samples, nil)
            }
        }
         
        HKHealthStore().execute(sampleQuery)
    }
    
    /// Saves BMI to user's health information.
    /// - Parameter bodyMassIndex: BMI value.
    /// - Parameter date: Date that the BMI was calculated.
    class func saveBodyMassIndexSample(bodyMassIndex: Double, date: Date) {
      
        guard let bodyMassIndexType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) else {
            fatalError("Body Mass Index Type not available")
        }
        
        let bodyMassQuantity = HKQuantity(unit: HKUnit.count(),
                                          doubleValue: bodyMassIndex)
        
        let bodyMassIndexSample = HKQuantitySample(type: bodyMassIndexType,
                                                   quantity: bodyMassQuantity,
                                                   start: date,
                                                   end: date)
        
        HKHealthStore().save(bodyMassIndexSample) { (success, error) in
            if let error = error {
                print("Error Saving BMI Sample: \(error.localizedDescription)")
            } else {
                print("Successfully saved BMI Sample")
            }
        }
    }
}

extension Date {
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}

//
//  HealthKitManager.swift
//  HealthKitPOC
//
//  Created by Matheus Oliveira on 10/11/20.
//

import HealthKit

protocol HealthKitManagerDelegate: class {
    func displayError(error: Error)
    func getHeight(height: Double)
    func getAgeSexAndBloodType(age: Int,
                               biologicalSex: HKBiologicalSex,
                               bloodType: HKBloodType)
    func getWeight(weight: Double)
    func getBodyMassIndex(bodyMassIndex: Double)
    func getSleepInformation(sleepInformation: String)
}

class HealthKitManager {
    
    weak var delegate: HealthKitManagerDelegate?
    
    /// Retrieve age, biological sex and blood type from
    /// HealthKit and update labels.
    public func querryAgeSexAndBloodType() {
        
        do {
            let age = try ProfileDataStore.getAge()
            let biologicalSex = try ProfileDataStore.getBiologicalSex()
            let bloodType = try ProfileDataStore.getBloodType()
            self.delegate?.getAgeSexAndBloodType(age: age,
                                                 biologicalSex: biologicalSex,
                                                 bloodType: bloodType)
        } catch let error {
            self.delegate?.displayError(error: error)
        }
    }

    /// Query last height information from HealthKit.
    public func querryHeight() {
        
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit")
            return
        }
            
        ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
              
            guard let sample = sample else {
                
                if let error = error {
                    self.delegate?.displayError(error: error)
                }
                
                return
            }
              
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.delegate?.getHeight(height: heightInMeters)
        }
    }
    
    /// Query last weight information from HealthKit and
    /// uptade labels.
    public func querryWeight() {
        
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }
            
        ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in
              
            guard let sample = sample else {
                
                if let error = error {
                    self.delegate?.displayError(error: error)
                }
                return
            }
              
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.delegate?.getWeight(weight: weightInKilograms)
        }
    }
    
    /// Query last BMI information from HealthKit and
    /// uptade labels.
    public func querryBodyMassIndex() {
        guard let bmiSampleType = HKSampleType.quantityType(forIdentifier: .bodyMassIndex) else {
            print("Body mass is not available")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: bmiSampleType) { (sample, error) in
            guard let sample = sample else {
                if let error = error {
                    self.delegate?.displayError(error: error)
                }
                return
            }
            let bodyMassIndex = sample.quantity.doubleValue(for: HKUnit.count())
            self.delegate?.getBodyMassIndex(bodyMassIndex: bodyMassIndex)
        }
    }
    
    /// Query last night sleep information from HealthKit
    public func querrySleepIformation() {
        guard let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep Analysis is not available")
            return
        }
        
        ProfileDataStore.getDayBeforeSample(for: sleepAnalysis) { [self] (samples, error) in
            guard let samples = samples else {
                if let error = error {
                    self.delegate?.displayError(error: error)
                }
                return
            }
            
            self.buildAndUpdateSleepInfo(samples: samples)
        }
    }
    
    /// Transform sleep information on a redable string and update labels
    /// - Parameter samples: An array of samples containing sleep
    /// information with inBed and asleep values.
    private func buildAndUpdateSleepInfo(samples: [HKSample]) {
        var totalHours: Int = 0
        var totalMinutes: Int = 0
        
        for sample in samples {
            if let sample = sample as? HKCategorySample {
                if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                    let diffComponents = Calendar.current.dateComponents([.hour, .minute],
                                                                         from: sample.startDate,
                                                                         to: sample.endDate)
                    let hours = diffComponents.hour
                    let minutes = diffComponents.minute
                    totalHours += hours ?? 0
                    totalMinutes += minutes ?? 0
                }
            }
        }
        
        let hours = totalMinutes / 60
        totalHours += hours
        totalMinutes -= hours * 60
        let sleepInformation = "\(totalHours) horas e \(totalMinutes) minutos"
        self.delegate?.getSleepInformation(sleepInformation: sleepInformation)
    }
}

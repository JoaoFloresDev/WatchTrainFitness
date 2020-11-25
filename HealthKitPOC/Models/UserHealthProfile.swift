//
//  UserHealthProfile.swift
//  HealthKitPOC
//
//  Created by Matheus Oliveira on 05/11/20.
//

import HealthKit

class UserHealthProfile {
  
    var name: String?
    var age: Int?
    var biologicalSex: HKBiologicalSex?
    var bloodType: HKBloodType?
    var height: Double?
    var weight: Double?
    var bodyMassIndex: Double?
    var lastnightSleepDuration: String?
}

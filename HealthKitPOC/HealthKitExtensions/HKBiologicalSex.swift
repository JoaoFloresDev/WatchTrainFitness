//
//  BiologicalSex.swift
//  HealthKitPOC
//
//  Created by Matheus Oliveira on 05/11/20.
//

import HealthKit

extension HKBiologicalSex {
    
    var stringRepresentation: String {
        switch self {
        case .notSet:
            return "Não informado"
        case .female:
            return "Feminino"
        case .male:
            return "Masculino"
        case .other:
            return "Outro"
        default:
            return "-"
        }
    }
}

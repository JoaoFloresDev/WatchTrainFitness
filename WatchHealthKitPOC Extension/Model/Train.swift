//
//  Train.swift
//  WatchHealthKitPOC Extension
//
//  Created by Joao Flores on 23/11/20.
//

import Foundation

enum TrainType {
	case paces //units
	case distance //meters
	case time //seconds
}

struct Train {
	var type: TrainType
	var targuet: Int
	var title: String
	var subtitle: String
}

//
//  OptionsController.swift
//  WatchHealthKitPOC Extension
//
//  Created by Joao Flores on 17/11/20.
//

import WatchKit
import Foundation
import HealthKit
import UserNotifications
import WatchConnectivity
import Foundation
import HealthKit
import Combine
import CoreMotion

class OptionsController: WKInterfaceController {

	//	MARK: - Variables
	var trains = [
		Train(type: .distance, targuet: 30, title: "Vida em movimento", subtitle: "Ande 30 metros"),
		Train(type: .distance, targuet: 100, title: "Vida em movimento", subtitle: "Ande 100 metros"),
		Train(type: .paces, targuet: 300, title: "Vida em movimento", subtitle: "Ande 300 passos"),
		Train(type: .time, targuet: 60, title: "Vida em movimento", subtitle: "Corra 1 minuto"),
	]

	//	MARK: - IBOutlet
	@IBOutlet weak var trainsTable: WKInterfaceTable!

	//	MARK: - IBActions
	@IBAction func requestLocalNotification() {
		NotificationManager().singleNotification()
	}

	//	MARK: - Life Cycle
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		NotificationManager().setupNotifications()

		trainsTable.setNumberOfRows(trains.count, withRowType: "RowController")

		for index in 0...(trains.count-1) {
			if let row = trainsTable.rowController(at: index) as? RowController {
				row.titleLabel.setText(trains[index].title)
				row.subtitleLabel.setText(trains[index].subtitle)
			}
		}
	}

	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		pushController(withName: "InterfaceController", context: trains[rowIndex])
	}
}


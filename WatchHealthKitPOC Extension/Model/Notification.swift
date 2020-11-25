//
//  NotificationManager.swift
//  WatchHealthKitPOC Extension
//
//  Created by Joao Flores on 11/11/20.
//

import WatchKit
import Foundation
import HealthKit
import UserNotifications
import WatchConnectivity
import Foundation
import HealthKit
import Combine

class NotificationManager {
	func singleNotification() {
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
		let content = UNMutableNotificationContent()
		content.title = NSLocalizedString("Beba Água", comment: "Local Notification Title")
		content.body = NSLocalizedString("Atalinha recomenda 2 litros de água diariamente", comment: "Local Notification Body")
		content.categoryIdentifier = "Local"

		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

		UNUserNotificationCenter.current().add(request)
	}

	func setupNotifications() {
		UNUserNotificationCenter.current()

		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in

			if let error = error {
				print(error.localizedDescription)
			}
		}
	}

	func setReminderNotification() {
		let content = UNMutableNotificationContent()
		content.title = "Beba Água"
		content.body = "Atalinha recomenda 2 litros de água diariamente"
		content.sound = UNNotificationSound.default

		let gregorian = Calendar(identifier: .gregorian)
		let now = Date()
		var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)

		components.hour = 13
		components.minute = 27
		components.second = 0

		let date = gregorian.date(from: components)!

		let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)


		let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
		print("INSIDE NOTIFICATION")

		UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
			if error != nil {
				print("SOMETHING WENT WRONG")
			}
		})
	}
}

class TimerManager {
	func secondsToHoursMinutesSeconds (seconds : Int) -> String {

		let hours = String(format: "%02d", seconds / 3600)
		let minuts = String(format: "%02d", (seconds % 3600) / 60)
		let seconds = String(format: "%02d", (seconds % 3600) % 60)
		return hours + ":" + minuts + ":" + seconds
	}

	func workoutConfiguration() -> HKWorkoutConfiguration {
		let configuration = HKWorkoutConfiguration()
		configuration.activityType = .running
		configuration.locationType = .outdoor


		return configuration
	}
}

class TypeExerciseManager {

	func initialLabels(train: Train) -> (distance: String, mensure: String) {

		var distance = ""
		var mensure = ""

		switch train.type {
			case TrainType.paces:
				distance = "0"
				mensure = "passos"

			case TrainType.time:
				distance = "00:00:00"
				mensure = ""

			default: // distance
				distance = "0.0"
				mensure = "metros"
		}

		return (distance, mensure)

	}

	func populateTargetLabel(train: Train) -> String {

		switch train.type {

			case TrainType.time:
				let time = TimerManager().secondsToHoursMinutesSeconds (seconds : train.targuet)
				return time

			case TrainType.paces:
				return "\(train.targuet) passos"

			default: //distance
				return "\(train.targuet)m"
		}
	}


}

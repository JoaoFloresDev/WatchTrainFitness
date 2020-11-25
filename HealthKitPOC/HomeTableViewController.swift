//
//  ViewController.swift
//  HealthKitPOC
//
//  Created by Matheus Oliveira on 04/11/20.
//

import UIKit
import HealthKit
import UserNotifications
import WatchConnectivity

private enum ProfileDataError: Error {
  
    case missingBodyMassIndex
  
    var localizedDescription: String {
        switch self {
            case .missingBodyMassIndex:
            return "Unable to calculate body mass index with available profile data."
        }
    }
}

class HomeTableViewController: UITableViewController, WCSessionDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAge: UILabel!
    @IBOutlet weak var userBloodType: UILabel!
    @IBOutlet weak var userHeight: UILabel!
    @IBOutlet weak var userBiologicalSex: UILabel!
    @IBOutlet weak var userWeight: UILabel!
    @IBOutlet weak var userBodyMassIndex: UILabel!
    @IBOutlet weak var sleep: UILabel!
    
    private let userHealthProfile: UserHealthProfile = UserHealthProfile()
    
    let name = "Matheus Oliveira"
    
    let healthKitManager = HealthKitManager()
    
	var wcSession : WCSession! = nil

	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

	}

	func sessionDidBecomeInactive(_ session: WCSession) {

	}

	func sessionDidDeactivate(_ session: WCSession) {

	}

	@IBAction func notificationAction(_ sender: Any) {
		print("notificação mandada")
		// Create Notification Content
		let notificationContent = UNMutableNotificationContent()

		// Configure Notification Content
		notificationContent.title = "TITLE"
		notificationContent.subtitle = "Subtitle"
		notificationContent.body = "Body"
		notificationContent.categoryIdentifier = "app.likedislike.ios10"

		// Add Trigger
		let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)

		// Create Notification Request
		let request = UNNotificationRequest(identifier: "app.likedislike.ios10",
											content: notificationContent, trigger: notificationTrigger)
		UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
			if let error = error {
				print("Error \(error)")
				// Something went wrong
			}
		})
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.text = name
        self.healthKitManager.delegate = self
        healthKitManager.querryAgeSexAndBloodType()
        healthKitManager.querryHeight()
        healthKitManager.querryWeight()
        healthKitManager.querrySleepIformation()
//        healthKitManager.querryBodyMassIndex()
        requestHKAutorization()
		wcSession = WCSession.default
		wcSession.delegate = self
		wcSession.activate()

		UNUserNotificationCenter.current().delegate = self

		authorizeNotification()
    }

	func authorizeNotification() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
			if let error = error {
				print("Error:- \(error)")
			} else if success == true {
				print("Permission Granted")
			}
		}
	}
    
    // MARK: - Update labels
    
    private func formatAndDisplayHeight(height: Double) {
        let heightFormatter = LengthFormatter()
        heightFormatter.isForPersonHeightUse = true
        userHeight.text = heightFormatter.string(for: height)
    }
    
    private func formatAndDisplayWeight(weight: Double) {
        let weightFormatter = MassFormatter()
        weightFormatter.isForPersonMassUse = true
        userWeight.text = weightFormatter.string(for: weight)
    }
    
    private func formatAndDisplayBMI(bodyMassIndex: Double) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        numberFormatter.maximumFractionDigits = 2
        userBodyMassIndex.text = numberFormatter.string(from: NSNumber(value: bodyMassIndex))
    }
    
    // MARK: - Calculate BMI
    @IBAction func calculateBMI(_ sender: Any) {
        guard let weight = self.userHealthProfile.weight,
              let height = self.userHealthProfile.height else { return }
        var bodyMassIndex = weight / (height * height)
        bodyMassIndex = round(100*bodyMassIndex)/100 // Rounding to 2 decimal places
        userBodyMassIndex.text = String(bodyMassIndex)
        ProfileDataStore.saveBodyMassIndexSample(bodyMassIndex: bodyMassIndex,
                                                 date: Date())
    }
    
    // MARK: - HealthKit authorization
    private func requestHKAutorization() {
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
              
        guard authorized else {
                
            let baseMessage = "HealthKit authorization failed"
                
            if let error = error {
                print("\(baseMessage). Reason: \(error.localizedDescription)")
            } else {
                print(baseMessage)
            }
                
            return
          }
              
        print("HealthKit Successfully Authorized.")
            
        }
    }
    
    // MARK: - Display alerts
    
    private func displayAlert(for error: Error) {
      let alert = UIAlertController(title: nil,
                                    message: error.localizedDescription,
                                    preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "Ok",
                                    style: .default,
                                    handler: nil))
      
      present(alert, animated: true, completion: nil)
    }

	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert])
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension HomeTableViewController: HealthKitManagerDelegate {
    
    func displayError(error: Error) {
        self.displayAlert(for: error)
    }
    
    func getAgeSexAndBloodType(age: Int, biologicalSex: HKBiologicalSex, bloodType: HKBloodType) {
        self.userHealthProfile.age = age
        self.userHealthProfile.biologicalSex = biologicalSex
        self.userHealthProfile.bloodType = bloodType
        userAge.text = "\(age) anos"
        userBiologicalSex.text = biologicalSex.stringRepresentation
        userBloodType.text = bloodType.stringRepresentation
    }
    
    func getHeight(height: Double) {
        self.userHealthProfile.height = height
        self.formatAndDisplayHeight(height: height)
    }
    
    func getWeight(weight: Double) {
        self.userHealthProfile.weight = weight
        formatAndDisplayWeight(weight: weight)
    }
    
    func getBodyMassIndex(bodyMassIndex: Double) {
        self.userHealthProfile.bodyMassIndex = bodyMassIndex
        self.formatAndDisplayBMI(bodyMassIndex: bodyMassIndex)
    }
    
    func getSleepInformation(sleepInformation: String) {
        self.userHealthProfile.lastnightSleepDuration = sleepInformation
        sleep.text = sleepInformation
    }
}

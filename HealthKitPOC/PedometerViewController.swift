//
//  PedometerViewController.swift
//  HealthKitPOC
//
//  Created by Matheus Oliveira on 16/11/20.
//

import UIKit
import CoreMotion

class PedometerViewController: UIViewController {

    @IBOutlet weak var stepCounter: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    let pedometer = CMPedometer()
    var backgroundMode: Bool = false
    var didPressedStart: Bool = false
    var startDate: Date = Date()
    var timer: Timer = Timer()
    var counter: Int = 0 {
        didSet {
            if backgroundMode == false {
                DispatchQueue.main.async {
                    self.stepCounter.text = String(self.counter)
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: Remove observers
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(didResumeApp),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startPedometer()
    }
    
    private func startPedometer() {
    }
    
    @objc func didEnterBackground() {
        self.backgroundMode = true
    }
    
    @objc func didResumeApp() {
        self.backgroundMode = false
    }
    
    @IBAction func startButton(_ sender: Any) {
        
        self.didPressedStart = !self.didPressedStart
        
        if didPressedStart {
            self.button.setTitle("Parar", for: .normal)
            self.startDate = Date()
            self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                              target: self,
                                              selector: #selector(updateTimerLabel),
                                              userInfo: nil,
                                              repeats: true)
            DispatchQueue.background {
                self.pedometer.startUpdates(from: self.startDate) { (data, error) in
                    self.counter = Int(truncating: data?.numberOfSteps ?? 0)
                }
            }
        }
        else {
            self.button.setTitle("Iniciar", for: .normal)
            self.timer.invalidate()
            self.pedometer.stopUpdates()
        }
    }
    
    @objc func updateTimerLabel() {
        let interval = -Int(startDate.timeIntervalSinceNow)
        let hours = interval / 3600
        let minutes = interval / 60 % 60
        let seconds = interval % 60

        timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
}

extension DispatchQueue {

    static func background(_ task: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            task()
        }
    }

    static func main(_ task: @escaping () -> ()) {
        DispatchQueue.main.async {
            task()
        }
    }
}

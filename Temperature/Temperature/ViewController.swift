//
//  ViewController.swift
//  Temperature
//
//  Created by Ian Terrell on 1/14/17.
//  Copyright © 2017 SPARK Hackathon. All rights reserved.
//

import UIKit
import ParticleSDK

class ViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!

    var device: SparkDevice?

    override func viewDidLoad() {
        super.viewDidLoad()
        startSession()
    }

    func startSession() {
        if SparkCloud.sharedInstance().injectSessionAccessToken(Config.shared.accessToken) {
            print("Session is active")
            getDevice()
        } else {
            print("Bad access token provided")
        }
    }

    func getDevice() {
        SparkCloud.sharedInstance().getDevice(Config.shared.deviceID) { device, error in
            guard let device = device, error == nil else {
                DispatchQueue.main.async {
                    self.titleLabel.text = "Error fetching device!"
                }
                if let error = error {
                    print("Error fetching device: \(error)")
                }
                return
            }

            self.device = device
            self.titleLabel.text = device.name
        }
    }
}

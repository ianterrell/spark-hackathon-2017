//
//  ViewController.swift
//  RGB
//
//  Created by Ian Terrell on 1/14/17.
//  Copyright © 2017 SPARK Hackathon. All rights reserved.
//

import UIKit
import ParticleSDK

class ViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var colorView: UIView!
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!

    var device: SparkDevice?

    let debounce = createDebouncer(delay: 0.5, queue: .main)

    override func viewDidLoad() {
        super.viewDidLoad()
        startSession()
        updateColorView()
    }

    @IBAction func sliderChanged(_ sender: Any) {
        updateColorView()
        debounce(updatePhoton)
    }

    func color() -> UIColor {
        return UIColor(red: CGFloat(redSlider.value / 255),
                       green: CGFloat(greenSlider.value / 255),
                       blue: CGFloat(blueSlider.value / 255), alpha: 1.0)
    }

    func updateColorView() {
        colorView.backgroundColor = color()
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

    func updatePhoton() {
        guard let device = device else {
            return
        }

        let arguments = colorParam()
        print("Calling led(\"\(arguments)\")")
        device.callFunction("led", withArguments: [arguments]) { number, error in
            if let error = error {
                print("Error calling function: \(error)")
                return
            }

            guard let number = number else {
                print("No response code")
                return
            }

            print("Call returned \(number)")
        }
    }

    func colorParam() -> String {
        let red = Int(255 - redSlider.value)
        let green = Int(255 - greenSlider.value)
        let blue = Int(255 - blueSlider.value)
        return "\(red),\(green),\(blue)"
    }
}

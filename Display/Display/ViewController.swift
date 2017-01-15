//
//  ViewController.swift
//  Display
//
//  Created by Ian Terrell on 1/14/17.
//  Copyright © 2017 SPARK Hackathon. All rights reserved.
//

import UIKit
import ParticleSDK

let kMaxCharacters = 168
let kMaxParameterCharacters = 63

class ViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var characterLabel: UILabel!
    
    var device: SparkDevice?

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 3
        textView.layer.cornerRadius = 5

        updateCharacterLabel(message: textView.text)
        startSession()
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        printToPhoton(message: textView.text)
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

    func printToPhoton(message: String) {
        guard let device = device else {
            return
        }

        // Spark has a limit of 63 characters per parameter, 
        // so we'll have to split up long messages and send them in chunks
        var ranges: [Range<String.Index>] = []
        let message = textView.text!
        let length = message.characters.count
        var index = message.startIndex
        while index < message.endIndex {
            let endIndex = message.index(index, offsetBy: kMaxParameterCharacters, limitedBy: message.endIndex) ?? message.endIndex
            ranges.append(Range(uncheckedBounds: (lower: index, upper: endIndex)))
            index = endIndex
        }

        var rangeIndex = 0
        func printNext() {
            guard ranges.count > rangeIndex else {
                return
            }
            let chunk = message.substring(with: ranges[rangeIndex])
            device.callFunction("print", withArguments: [chunk as Any]) { number, error in
                if let error = error {
                    print("Error calling print: \(error)")
                    return
                }

                guard let number = number else {
                    print("No response code from print")
                    return
                }

                print("Print returned \(number), calling printNext")
                rangeIndex += 1
                printNext()
            }
        }

        print("Calling clear()")
        device.callFunction("clear", withArguments: []) { number, error in
            if let error = error {
                print("Error calling clear: \(error)")
                return
            }

            guard let number = number else {
                print("No response code from clear")
                return
            }

            print("Clear returned \(number), calling printNext")
            printNext()
        }
    }

    func colorParam() -> String {
        return ""
    }
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let nsString = textView.text as NSString
        let newString = nsString.replacingCharacters(in: range, with: text)
        let shouldChange = newString.characters.count <= kMaxCharacters
        if shouldChange {
            updateCharacterLabel(message: newString)
        }
        return shouldChange
    }

    func updateCharacterLabel(message: String) {
        characterLabel.text = "\(message.characters.count) / \(kMaxCharacters)"
    }
}

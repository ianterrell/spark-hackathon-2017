//
//  Config.swift
//  RGB
//
//  Created by Ian Terrell on 1/14/17.
//  Copyright © 2017 SPARK Hackathon. All rights reserved.
//

import Foundation

final class Config {
    static let shared = Config()

    let accessToken: String
    let deviceID: String

    private init() {
        let path = Bundle.main.path(forResource: "Config", ofType: "plist")!
        let config = NSDictionary(contentsOfFile: path)!

        accessToken = config.extract("ACCESS_TOKEN")
        deviceID = config.extract("DEVICE_ID")
    }
}

private extension NSDictionary {
    func extract(_ key: String) -> String {
        // swiftlint:disable:next force_cast
        return self[key] as! String
    }

    func extract(_ key: String) -> URL {
        return URL(string: extract(key))!
    }
}

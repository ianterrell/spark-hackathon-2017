//
//  Debounce.swift
//  RGB
//
//  Created by Ian Terrell on 1/14/17.
//  Copyright © 2017 SPARK Hackathon. All rights reserved.
//

import Foundation

public typealias Debouncer = (@escaping () -> Void) -> Void

public func createDebouncer(delay: TimeInterval, queue: DispatchQueue) -> Debouncer {
    var lastCalled: DispatchTime = DispatchTime(uptimeNanoseconds: 0)
    let delay: DispatchTimeInterval = .milliseconds(Int(delay * 1000.0))

    return { action in
        let called = DispatchTime.now()
        lastCalled = called

        queue.asyncAfter(deadline: DispatchTime.now() + delay) {
            let executeAfter = lastCalled + delay
            if called >= lastCalled && DispatchTime.now() >= executeAfter {
                action()
            }
        }
    }
}

//
//  DispatchSemaphoreWrapper.swift
//  Niceter
//
//  Created by uuttff8 on 5/1/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import Foundation

public struct DispatchSemaphoreWrapper {
    let s = DispatchSemaphore(value: 1)
    init() {}
    func sync<R>(execute: () throws -> R) rethrows -> R {
        print("WAIT SEMAPHORE")
        _ = s.wait(timeout: DispatchTime.distantFuture)
        defer {
            s.signal()
            print("SIGNAL SEMAPHORE")
        }
        return try execute()
    }
}

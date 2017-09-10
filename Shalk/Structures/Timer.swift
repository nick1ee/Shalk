//
//  Timer.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/14.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: Timer

import UIKit

private let timerQueue = DispatchQueue(label: "com.timer.queue", attributes: [])

final class Timer: NSObject {

    // MARK: Property

    private var timer: DispatchSourceTimer?

    var active: Bool {

        return timer != nil

    }

    // MARK: Methods

    func start(_ startPoint: DispatchTime, interval: Int, repeats: Bool = false, handler: @escaping () -> Void) {

        cancel()

        let timer = DispatchSource.makeTimerSource(queue: timerQueue)

        self.timer = timer

        timer.scheduleRepeating(
            deadline: startPoint,
            interval: .seconds(interval)
        )

        timer.setEventHandler {

            if !repeats {

                self.cancel()

            }

            DispatchQueue.main.async(execute: handler)

        }

        timer.resume()

    }

    func cancel() {

        if let timer = timer {

            timer.cancel()

            self.timer = nil

        }
    }

    deinit {

        cancel()

    }

}

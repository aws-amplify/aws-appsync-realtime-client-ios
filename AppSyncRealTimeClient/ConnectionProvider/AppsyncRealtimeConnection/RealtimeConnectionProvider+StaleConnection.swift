//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension RealtimeConnectionProvider {

    /// Start a stale connection timer, first invalidating and destroying any existing timer
    func startStaleConnectionTimer() {
        AppSyncLogger.debug("Starting stale connection timer for \(staleConnectionTimeout)s")
        if keepAliveTimer != nil {
            stopStaleConnectionTimer()
        }
        keepAliveTimer = CountdownTimer(interval: staleConnectionTimeout) {
            self.disconnectStaleConnection()
        }
    }

    /// Stop and destroy any existing stale connection timer
    func stopStaleConnectionTimer() {
        AppSyncLogger.debug("Stopping and destroying stale connection timer")
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
    }

    /// Reset the stale connection timer in response to receiving a message
    func resetStaleConnectionTimer() {
        AppSyncLogger.debug("Resetting stale connection timer")
        keepAliveTimer?.resetCountdown()
    }

    /// Fired when the stale connection timer expires
    private func disconnectStaleConnection() {
        serialConnectionQueue.async {[weak self] in
            guard let self = self else {
                return
            }
            self.status = .notConnected
            self.websocket.disconnect()
            AppSyncLogger.error("Realtime connection is stale, disconnected.")
            self.updateCallback(event: .error(ConnectionProviderError.connection))
        }
    }

}

extension RealtimeConnectionProvider {

    /// A resettable timer that executes `onCountdownComplete` after `interval`
    class CountdownTimer {
        /// The interval after which the timer will fire
        let interval: TimeInterval

        private var timer: Timer?
        private let onCountdownComplete: () -> Void
        private let queue: DispatchQueue

        init(interval: TimeInterval, onCountdownComplete: @escaping () -> Void) {
            self.interval = interval
            self.onCountdownComplete = onCountdownComplete
            self.queue = DispatchQueue(
                label: "CountdownTimer queue",
                target: DispatchQueue.global()
            )
            createAndScheduleTimer()
        }

        /// Resets the countdown of the timer to `interval`
        func resetCountdown() {
            invalidate()
            createAndScheduleTimer()
        }

        /// Invalidates the timer
        func invalidate() {
            queue.sync {
                timer?.invalidate()
                timer = nil
            }
        }

        /// Invoked by the timer. Do not execute this method directly.
        @objc private func timerFired() {
            onCountdownComplete()
            timer = nil
        }

        private func createAndScheduleTimer() {
            let timer = Timer.scheduledTimer(
                timeInterval: interval,
                target: self,
                selector: #selector(timerFired),
                userInfo: nil,
                repeats: false
            )
            self.timer = timer

            queue.sync {
                RunLoop.current.add(timer, forMode: .default)
            }
        }

    }

}

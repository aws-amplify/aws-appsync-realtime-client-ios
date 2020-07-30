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

//
// Copyright 2018-2021 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension RealtimeConnectionProvider {

    /// Start a stale connection timer, first invalidating and destroying any existing timer
    func startStaleConnectionTimer() {
        AppSyncLogger.debug("[RealtimeConnectionProvider] Starting stale connection timer for \(staleConnectionTimeout.get())s")
        if staleConnectionTimer != nil {
            stopStaleConnectionTimer()
        }
        staleConnectionTimer = CountdownTimer(interval: staleConnectionTimeout.get()) {
            self.disconnectStaleConnection()
        }
    }

    /// Stop and destroy any existing stale connection timer
    func stopStaleConnectionTimer() {
        AppSyncLogger.debug("[RealtimeConnectionProvider] Stopping and destroying stale connection timer")
        staleConnectionTimer?.invalidate()
        staleConnectionTimer = nil
    }

    /// Reset the stale connection timer in response to receiving a message
    func resetStaleConnectionTimer() {
        AppSyncLogger.debug("[RealtimeConnectionProvider] Resetting stale connection timer")
        staleConnectionTimer?.resetCountdown()
    }

    /// Handle updates from the ConnectivityMonitor
    func handleConnectivityUpdates(connectivity: ConnectivityPath) {
        connectionQueue.async {[weak self] in
            guard let self = self else {
                return
            }
            AppSyncLogger.debug("[RealtimeConnectionProvider] Status: \(self.status). Connectivity status: \(connectivity.status)")
            if self.status == .connected && connectivity.status == .unsatisfied && !self.isStaleConnection {
                AppSyncLogger.debug("[RealtimeConnectionProvider] Connetion is stale. Pending reconnect on connectivity.")
                self.isStaleConnection = true

            } else if self.status == .connected && self.isStaleConnection && connectivity.status == .satisfied {
                AppSyncLogger.debug("[RealtimeConnectionProvider] Connetion is stale. Disconnecting to begin reconnect.")
                if self.staleConnectionTimer != nil {
                    self.stopStaleConnectionTimer()
                }

                self.disconnectStaleConnection()
            }
        }
    }

    /// Fired when the stale connection timer expires
    private func disconnectStaleConnection() {
        connectionQueue.async {[weak self] in
            guard let self = self else {
                return
            }
            AppSyncLogger.error("[RealtimeConnectionProvider] Realtime connection is stale, disconnecting.")
            self.status = .notConnected
            self.isStaleConnection = false
            self.websocket.disconnect()
            self.updateCallback(event: .error(ConnectionProviderError.connection))
        }
    }
}

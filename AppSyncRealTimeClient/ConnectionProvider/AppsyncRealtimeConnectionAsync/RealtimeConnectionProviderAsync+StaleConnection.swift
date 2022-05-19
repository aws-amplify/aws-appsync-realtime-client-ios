//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

#if swift(>=5.5.2)

/// Consolidates usage and parameters passed to the `staleConnectionTimer` methods.
@available(iOS 13.0, *)
extension RealtimeConnectionProviderAsync {

    /// Start a stale connection timer, first invalidating and destroying any existing timer
    func startStaleConnectionTimer() {
        AppSyncLogger.debug(
            "[RealtimeConnectionProvider] Starting stale connection timer for \(staleConnectionTimer.interval)s"
        )

        staleConnectionTimer.start(interval: RealtimeConnectionProviderBase.staleConnectionTimeout) {
            self.disconnectStaleConnection()
        }
    }

    /// Reset the stale connection timer in response to receiving a message from the websocket
    func resetStaleConnectionTimer(interval: TimeInterval? = nil) {
        AppSyncLogger.verbose("[RealtimeConnectionProvider] Resetting stale connection timer")
        staleConnectionTimer.reset(interval: interval)
    }

    /// Stops the timer when disconnecting the websocket.
    func invalidateStaleConnectionTimer() {
        staleConnectionTimer.invalidate()
    }

    /// Handle updates from the ConnectivityMonitor
    func handleConnectivityUpdates(connectivity: ConnectivityPath) {
        Task {
            AppSyncLogger.debug(
                "[RealtimeConnectionProvider] Status: \(status). Connectivity status: \(connectivity.status)"
            )
            if status == .connected && connectivity.status == .unsatisfied && !isStaleConnection {
                AppSyncLogger.debug(
                    "[RealtimeConnectionProvider] Connetion is stale. Pending reconnect on connectivity."
                )
                isStaleConnection = true

            } else if status == .connected && isStaleConnection && connectivity.status == .satisfied {
                AppSyncLogger.debug(
                    "[RealtimeConnectionProvider] Connetion is stale. Disconnecting to begin reconnect."
                )
                staleConnectionTimer.invalidate()
                disconnectStaleConnection()
            }
        }
    }

    /// Fired when the stale connection timer expires
    private func disconnectStaleConnection() {
        Task {
            AppSyncLogger.error("[RealtimeConnectionProvider] Realtime connection is stale, disconnecting.")
            status = .notConnected
            isStaleConnection = false
            await self.websocket.disconnect()
            updateCallback(event: .error(ConnectionProviderError.connection))
        }
    }
}
#endif

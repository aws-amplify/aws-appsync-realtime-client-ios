//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import AppSyncRealTimeClient

class MockConnectivityMonitor: AnyConnectivityMonitor {

    private var connectivityUpdatesQueue: DispatchQueue?
    private var onConnectivityUpdates: ConnectivityUpdates?

    func start(
        connectivityUpdatesQueue: DispatchQueue,
        onConnectivityUpdates: @escaping ConnectivityUpdates
    ) {
        self.connectivityUpdatesQueue = connectivityUpdatesQueue
        self.onConnectivityUpdates = onConnectivityUpdates
    }

    func sendConnectivityUpdate(_ connectivityPath: ConnectivityPath) {
        guard let onConnectivityUpdates = onConnectivityUpdates,
              let connectivityUpdatesQueue = connectivityUpdatesQueue else {
            return
        }
        connectivityUpdatesQueue.async {
            onConnectivityUpdates(connectivityPath)
        }
    }

    func cancel() {
    }
}

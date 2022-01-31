//
// Copyright 2018-2021 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Network

typealias ConnectivityUpdates = (ConnectivityPath) -> Void

protocol AnyConnectivityMonitor {
    func start(connectivityUpdatesQueue: DispatchQueue, onConnectivityUpdates: @escaping ConnectivityUpdates)
    func cancel()
}

class ConnectivityMonitor {
    var connectivity: ConnectivityPath?

    private let connectivityUpdatesQueue = DispatchQueue(
        label: "com.amazonaws.ConnectivityMonitor.connectivityUpdatesQueue",
        qos: .background
    )
    private var monitor: AnyConnectivityMonitor?

    init(connectivityMonitor: AnyConnectivityMonitor? = nil) {
        self.monitor = connectivityMonitor
    }

    func start(connectivityUpdates: @escaping ConnectivityUpdates) {
        if let monitor = monitor {
            monitor.start(
                connectivityUpdatesQueue: connectivityUpdatesQueue,
                onConnectivityUpdates: connectivityUpdates
            )
        } else if #available(iOS 12.0, *) {
            let monitor = NetworkMonitor()
            self.monitor = monitor
            monitor.start(
                connectivityUpdatesQueue: connectivityUpdatesQueue,
                onConnectivityUpdates: connectivityUpdates
            )
        }
    }

    func cancel() {
        guard let monitor = monitor else {
            return
        }
        monitor.cancel()
        self.monitor = nil
    }

    deinit {
        cancel()
    }
}

@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 6.0, *)
class NetworkMonitor: AnyConnectivityMonitor {
    private var monitor: NWPathMonitor?
    private var onConnectivityUpdates: ConnectivityUpdates?
    private var connectivityUpdatesQueue: DispatchQueue?
    private let queue = DispatchQueue(label: "com.amazonaws.NetworkMonitor.queue", qos: .background)

    func start(connectivityUpdatesQueue: DispatchQueue, onConnectivityUpdates: @escaping ConnectivityUpdates) {
        self.connectivityUpdatesQueue = connectivityUpdatesQueue
        self.onConnectivityUpdates = onConnectivityUpdates
        // A new instance is required each time a monitor is started
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = didUpdate(path:)
        monitor.start(queue: queue)
        self.monitor = monitor
    }

    func cancel() {
        guard let monitor = monitor else { return }
        defer {
            self.monitor = nil
        }
        monitor.cancel()
    }

    func didUpdate(path: NWPath) {
        guard let onConnectivityUpdates = onConnectivityUpdates,
              let connectivityUpdatesQueue = connectivityUpdatesQueue else {
            return
        }
        let connectivityPath = ConnectivityPath(path: path)
        connectivityUpdatesQueue.async {
            onConnectivityUpdates(connectivityPath)
        }
    }
}

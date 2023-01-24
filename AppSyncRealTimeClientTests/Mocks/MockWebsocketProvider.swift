//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AppSyncRealTimeClient

class MockWebsocketProvider: AppSyncWebsocketProvider {
    typealias OnConnect = (URLRequest, [String], AppSyncWebsocketDelegate?) -> Void
    typealias OnDisconnect = () -> Void
    typealias OnWrite = (String) -> Void

    var isConnected: Bool

    let onConnect: OnConnect?
    let onDisconnect: OnDisconnect?
    let onWrite: OnWrite?

    init(
        onConnect: OnConnect? = nil,
        onDisconnect: OnDisconnect? = nil,
        onWrite: OnWrite? = nil
    ) {
        self.isConnected = false
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        self.onWrite = onWrite
    }

    func connect(urlRequest: URLRequest, protocols: [String], delegate: AppSyncWebsocketDelegate?) {
        onConnect?(urlRequest, protocols, delegate)
    }

    func disconnect() {
        onDisconnect?()
    }

    func write(message: String) {
        onWrite?(message)
    }

}

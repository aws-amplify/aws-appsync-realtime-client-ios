//
// Copyright 2018-2021 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AppSyncRealTimeClient

class MockWebsocketProvider: AppSyncWebsocketProvider {
    typealias OnConnect = (URL, [String], AppSyncWebsocketDelegate?) -> Void
    typealias OnDisconnect = () -> Void
    typealias OnWrite = (String) -> Void

    var isConnected: Bool

    let onConnect: OnConnect
    let onDisconnect: OnDisconnect
    let onWrite: OnWrite

    init(
        onConnect: @escaping OnConnect,
        onDisconnect: @escaping OnDisconnect,
        onWrite: @escaping OnWrite
    ) {
        self.isConnected = false
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        self.onWrite = onWrite
    }

    func connect(url: URL, protocols: [String], delegate: AppSyncWebsocketDelegate?) {
        onConnect(url, protocols, delegate)
    }

    func disconnect() {
        onDisconnect()
    }

    func write(message: String) {
        onWrite(message)
    }

}

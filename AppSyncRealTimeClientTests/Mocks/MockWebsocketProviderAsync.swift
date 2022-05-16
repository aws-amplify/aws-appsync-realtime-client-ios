//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AppSyncRealTimeClient

@available(iOS 13.0.0, *)
class MockWebsocketProviderAsync: AppSyncWebsocketProviderAsync {
    typealias OnConnect = (URL, [String], AppSyncWebsocketDelegateAsync?) async -> Void
    typealias OnDisconnect = () async -> Void
    typealias OnWrite = (String) async -> Void

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

    func connect(url: URL, protocols: [String], delegate: AppSyncWebsocketDelegateAsync?) async {
        await onConnect?(url, protocols, delegate)
    }

    func disconnect() async {
        await onDisconnect?()
    }

    func write(message: String) async {
        await onWrite?(message)
    }

}

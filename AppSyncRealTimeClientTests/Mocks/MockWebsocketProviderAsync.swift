//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AppSyncRealTimeClient

@available(iOS 13.0.0, *)
actor MockWebsocketProviderAsync: AppSyncWebsocketProviderAsync {
    typealias OnConnect = (URL, [String], AppSyncWebsocketDelegateAsync?) -> Void
    typealias OnDisconnect = () -> Void
    typealias OnWrite = (String) async -> Void

    // swiftlint:disable:next identifier_name
    var _isConnected: Bool

    func isConnected() async -> Bool {
        _isConnected
    }

    let onConnect: OnConnect?
    let onDisconnect: OnDisconnect?
    let onWrite: OnWrite?

    init(
        onConnect: OnConnect? = nil,
        onDisconnect: OnDisconnect? = nil,
        onWrite: OnWrite? = nil
    ) {
        self._isConnected = false
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        self.onWrite = onWrite
    }

    func connect(url: URL, protocols: [String], delegate: AppSyncWebsocketDelegateAsync?) async {
        onConnect?(url, protocols, delegate)
    }

    func disconnect() async {
        onDisconnect?()
    }

    func write(message: String) async {
        await onWrite?(message)
    }

}

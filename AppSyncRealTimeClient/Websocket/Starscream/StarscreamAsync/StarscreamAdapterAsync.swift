//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Starscream

@available(iOS 13.0.0, *)
public actor StarscreamAdapterAsync: AppSyncWebsocketProviderAsync {
    var socket: WebSocket?
    weak var delegate: AppSyncWebsocketDelegateAsync?

    let taskQueue = TaskQueue<Void>()

    var _isConnected: Bool

    public func isConnected() -> Bool {
        _isConnected
    }

    public init() {
        self._isConnected = false
    }

    public nonisolated func connect(url: URL, protocols: [String], delegate: AppSyncWebsocketDelegateAsync?) {
        taskQueue.async { [weak self] in
            await self?._connect(url: url, protocols: protocols, delegate: delegate)
        }
    }

    private func _connect(url: URL, protocols: [String], delegate: AppSyncWebsocketDelegateAsync?) {
        AppSyncLogger.verbose("[StarscreamAdapter] connect. Connecting to url")
        var urlRequest = URLRequest(url: url)
        let protocolHeaderValue = protocols.joined(separator: ", ")
        urlRequest.setValue(protocolHeaderValue, forHTTPHeaderField: "Sec-WebSocket-Protocol")
        socket = WebSocket(request: urlRequest)
        self.delegate = delegate
        socket?.delegate = self
        socket?.connect()
    }

    public nonisolated func disconnect() {
        taskQueue.async { [weak self] in
            await self?._disconnect()
        }
    }

    private func _disconnect() {
        AppSyncLogger.verbose("[StarscreamAdapter] socket.disconnect")
        socket?.disconnect()
        socket = nil
    }

    public nonisolated func write(message: String) {
        taskQueue.async { [weak self] in
            await self?._write(message: message)
        }
    }

    private func _write(message: String) {
        taskQueue.async { [weak self] in
            AppSyncLogger.verbose("[StarscreamAdapter] socket.write - \(message)")
            await self?.socket?.write(string: message)
        }
    }
}

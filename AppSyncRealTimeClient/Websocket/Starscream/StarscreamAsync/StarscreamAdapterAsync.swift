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

    var _isConnected: Bool

    public func isConnected() -> Bool {
        _isConnected
    }

    func setIsConnected(_ isConnected: Bool) {
        _isConnected = isConnected
    }

    public init() {
        self._isConnected = false
    }

    public func connect(url: URL, protocols: [String], delegate: AppSyncWebsocketDelegateAsync?) async {
        Task {
            AppSyncLogger.verbose("[StarscreamAdapter] connect. Connecting to url")
            var urlRequest = URLRequest(url: url)
            let protocolHeaderValue = protocols.joined(separator: ", ")
            urlRequest.setValue(protocolHeaderValue, forHTTPHeaderField: "Sec-WebSocket-Protocol")
            socket = WebSocket(request: urlRequest)
            self.delegate = delegate
            socket?.delegate = self
            socket?.connect()
        }
    }

    public func disconnect() async {
        Task {
            AppSyncLogger.verbose("[StarscreamAdapter] socket.disconnect")
            self.socket?.disconnect()
            self.socket = nil
        }
    }

    public func write(message: String) async {
        Task {
            AppSyncLogger.verbose("[StarscreamAdapter] socket.write - \(message)")
            self.socket?.write(string: message)
        }
    }
}

//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Starscream

public class StarscreamAdapter: AppSyncWebsocketProvider {
    let serialQueue: DispatchQueue
    private let callbackQueue: DispatchQueue

    var socket: WebSocket?
    weak var delegate: AppSyncWebsocketDelegate?

    // swiftlint:disable:next identifier_name
    var _isConnected: Bool
    public var isConnected: Bool {
        serialQueue.sync {
            _isConnected
        }
    }

    let watchOSConnectivityTimer: CountdownTimer
    
    public init() {
        let serialQueue = DispatchQueue(label: "com.amazonaws.StarscreamAdapter.serialQueue")
        let callbackQueue = DispatchQueue(
            label: "com.amazonaws.StarscreamAdapter.callBack",
            target: serialQueue
        )
        self._isConnected = false
        self.serialQueue = serialQueue
        self.callbackQueue = callbackQueue
        self.watchOSConnectivityTimer = CountdownTimer()
    }

    public func connect(urlRequest: URLRequest, protocols: [String], delegate: AppSyncWebsocketDelegate?) {
        serialQueue.async {
            AppSyncLogger.verbose("[StarscreamAdapter] connect. Connecting to url")
            var urlRequest = urlRequest

            urlRequest.setValue("no-store", forHTTPHeaderField: "Cache-Control")

            let protocolHeaderValue = protocols.joined(separator: ", ")
            urlRequest.setValue(protocolHeaderValue, forHTTPHeaderField: "Sec-WebSocket-Protocol")

            self.socket = WebSocket(request: urlRequest)
            self.delegate = delegate
            self.socket?.delegate = self
            self.socket?.callbackQueue = self.callbackQueue
            self.socket?.connect()
            #if os(watchOS)
            AppSyncLogger.debug(
                "[StarscreamAdapter] Starting connectivity timer for watchOS for 3s."
            )
            self.watchOSConnectivityTimer.start(interval: 3) {
                AppSyncLogger.debug(
                    "[StarscreamAdapter] watchOS connectivity timer is up."
                )
                self.serialQueue.async {
                    if !self._isConnected {
                        AppSyncLogger.debug(
                            "[StarscreamAdapter] watchOS subscriptions not connected after 3s."
                        )
                        AppSyncLogger.debug(
                            "[StarscreamAdapter] Manually send disconnect."
                        )
                        self.delegate?.websocketDidDisconnect(provider: self, error: nil)
                    } else {
                        AppSyncLogger.debug(
                            "[StarscreamAdapter] watchOS subscriptions are connected within 3s."
                        )
                    }
                }
                
            }
            #endif
        }
    }

    public func disconnect() {
        serialQueue.async {
            AppSyncLogger.verbose("[StarscreamAdapter] socket.disconnect")
            self.socket?.disconnect()
            self.socket = nil
        }
    }

    public func write(message: String) {
        serialQueue.async {
            AppSyncLogger.verbose("[StarscreamAdapter] socket.write - \(message)")
            self.socket?.write(string: message)
        }
    }
}

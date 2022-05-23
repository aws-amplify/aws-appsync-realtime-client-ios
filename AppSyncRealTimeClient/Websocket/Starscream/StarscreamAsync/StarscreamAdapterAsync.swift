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
    
    let taskSerializer = SerialTasks<Void>()
    
    public func isConnected() -> Bool {
        _isConnected
    }
    
    func setIsConnected(_ isConnected: Bool) {
        _isConnected = isConnected
    }
    
    public init() {
        self._isConnected = false
    }
    
    private func setSocket(_ webSocket: WebSocket?) {
        self.socket = webSocket
    }
    
    private func setDelegate(_ delegate: AppSyncWebsocketDelegateAsync?) {
        self.delegate = delegate
    }
    
    public func connect(url: URL, protocols: [String], delegate: AppSyncWebsocketDelegateAsync?) async {
        Task {
            await taskSerializer.add {
                Task {
                    AppSyncLogger.verbose("[StarscreamAdapter] connect. Connecting to url")
                    var urlRequest = URLRequest(url: url)
                    let protocolHeaderValue = protocols.joined(separator: ", ")
                    urlRequest.setValue(protocolHeaderValue, forHTTPHeaderField: "Sec-WebSocket-Protocol")
                    await self.setSocket(WebSocket(request: urlRequest))
                    await self.setDelegate(delegate)
                    await self.socket?.delegate = self
                    await self.socket?.connect()
                }
            }
        }
    }
    
    public func disconnect() async {
        Task {
            await taskSerializer.add {
                Task {
                    AppSyncLogger.verbose("[StarscreamAdapter] socket.disconnect")
                    await self.socket?.disconnect()
                    await self.setSocket(nil)
                }
            }
        }
    }
    
    public func write(message: String) async {
        Task {
            await taskSerializer.add {
                Task {
                    AppSyncLogger.verbose("[StarscreamAdapter] socket.write - \(message)")
                    await self.socket?.write(string: message)
                }
            }
        }
    }
}

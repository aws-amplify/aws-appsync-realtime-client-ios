//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Starscream

/// Extension to handle delegate callback from Starscream
@available(iOS 13.0.0, *)
extension StarscreamAdapterAsync: Starscream.WebSocketDelegate {
    public nonisolated func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected:
            websocketDidConnect(socket: client)
        case .disconnected(let reason, let code):
            AppSyncLogger.verbose("[StarscreamAdapter] disconnected: reason=\(reason); code=\(code)")
            websocketDidDisconnect(socket: client, error: nil)
        case .text(let string):
            websocketDidReceiveMessage(socket: client, text: string)
        case .binary(let data):
            websocketDidReceiveData(socket: client, data: data)
        case .ping:
            AppSyncLogger.verbose("[StarscreamAdapter] ping")
        case .pong:
            AppSyncLogger.verbose("[StarscreamAdapter] pong")
        case .viabilityChanged(let viability):
            AppSyncLogger.verbose("[StarscreamAdapter] viabilityChanged: \(viability)")
        case .reconnectSuggested(let suggestion):
            AppSyncLogger.verbose("[StarscreamAdapter] reconnectSuggested: \(suggestion)")
        case .cancelled:
            websocketDidDisconnect(socket: client, error: nil)
        case .error(let error):
            websocketDidDisconnect(socket: client, error: error)
        }
    }
    
    private nonisolated func websocketDidConnect(socket: WebSocketClient) {
        AppSyncLogger.verbose("[StarscreamAdapter] websocketDidConnect: websocket has been connected.")
        Task {
            await taskSerializer.add {
                Task {
                    await self.setIsConnected(true)
                    await self.delegate?.websocketDidConnect(provider: self)
                }
            }
        }
    }
    
    private nonisolated func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        Task {
            await taskSerializer.add {
                AppSyncLogger.verbose(
                    "[StarscreamAdapter] websocketDidDisconnect: \(error?.localizedDescription ?? "No error")"
                )
                Task {
                    await self.setIsConnected(false)
                    await self.delegate?.websocketDidDisconnect(provider: self, error: error)
                }
            }
        }
    }
    
    private nonisolated func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        Task {
            await taskSerializer.add {
                AppSyncLogger.verbose("[StarscreamAdapter] websocketDidReceiveMessage: - \(text)")
                let data = text.data(using: .utf8) ?? Data()
                Task {
                    await self.delegate?.websocketDidReceiveData(provider: self, data: data)
                }
            }
        }
    }
    
    private nonisolated func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        Task {
            await taskSerializer.add {
                AppSyncLogger.verbose("[StarscreamAdapter] WebsocketDidReceiveData - \(data)")
                Task {
                    await self.delegate?.websocketDidReceiveData(provider: self, data: data)
                }
            }
        }
    }
}

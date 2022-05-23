//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Protocol to be implemented by different websocket providers
@available(iOS 13.0.0, *)
public protocol AppSyncWebsocketProviderAsync {

    /// Initiates a connection to the given url.
    ///
    /// This is an async call. After the connection is succesfully established, the delegate
    /// will receive the callback on `websocketDidConnect(:)`
    func connect(url: URL, protocols: [String], delegate: AppSyncWebsocketDelegateAsync?)

    /// Disconnects the websocket.
    func disconnect()

    /// Write message to the websocket provider
    /// - Parameter message: Message to write
    func write(message: String)

    /// Returns `true` if the websocket is connected
    func isConnected() async -> Bool
}

/// Delegate method to get callbacks on websocket provider connection
@available(iOS 13.0.0, *)
public protocol AppSyncWebsocketDelegateAsync: AnyObject {

    func websocketDidConnect(provider: AppSyncWebsocketProviderAsync) async

    func websocketDidDisconnect(provider: AppSyncWebsocketProviderAsync, error: Error?) async

    func websocketDidReceiveData(provider: AppSyncWebsocketProviderAsync, data: Data) async
}

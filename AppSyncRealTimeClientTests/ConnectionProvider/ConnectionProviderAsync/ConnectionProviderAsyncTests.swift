//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

class ConnectionProviderAsyncTests: RealtimeConnectionProviderTestBase {

    /// Provider test
    ///
    /// Given:
    /// - A configured subscriber -> provider -> websocket chain
    /// When:
    /// - I invoke `provider.connect()`
    /// - And the websocket properly connects
    /// Then:
    /// - The subscriber is notified of the successful connection
    func testSuccessfulConnection() {
        receivedNotConnected.isInverted = true
        receivedError.isInverted = true

        let onConnect: MockWebsocketProvider.OnConnect = { _, _, delegate in
            self.websocketDelegate = delegate
            DispatchQueue.global().async {
                delegate?.websocketDidConnect(provider: self.websocket)
            }
        }

        let onDisconnect: MockWebsocketProvider.OnDisconnect = { }

        let onWrite: MockWebsocketProvider.OnWrite = { message in
            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
                XCTFail("Incoming message did not have 'connection_init' type")
                return
            }

            self.websocketDelegate.websocketDidReceiveData(
                provider: self.websocket,
                data: RealtimeConnectionProviderTestBase.makeConnectionAckMessage()
            )
        }

        websocket = MockWebsocketProvider(
            onConnect: onConnect,
            onDisconnect: onDisconnect,
            onWrite: onWrite
        )

        // Retain the provider so it doesn't release prior to executing callbacks
        let provider = createProviderAndConnect()

        // Get rid of "written to, but never read" compiler warnings
        print(provider)

        waitForExpectations(timeout: 0.05)
    }

    /// Provider add and remove listeners tests
    ///
    /// Given:
    /// - A connected websocket with a listener
    /// When:
    /// - remove all listeners
    /// Then:
    /// - The listeners are removed and the connection is disconnected
    func testAddRemoveListeners() {
        receivedNotConnected.isInverted = true
        receivedError.isInverted = true

        let onConnect: MockWebsocketProvider.OnConnect = { _, _, delegate in
            self.websocketDelegate = delegate
            DispatchQueue.global().async {
                delegate?.websocketDidConnect(provider: self.websocket)
            }
        }

        let receivedDisconnect = expectation(description: "receivedDisconnect")
        let onDisconnect: MockWebsocketProvider.OnDisconnect = {
            receivedDisconnect.fulfill()
        }

        let onWrite: MockWebsocketProvider.OnWrite = { message in
            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
                XCTFail("Incoming message did not have 'connection_init' type")
                return
            }

            self.websocketDelegate.websocketDidReceiveData(
                provider: self.websocket,
                data: RealtimeConnectionProviderTestBase.makeConnectionAckMessage()
            )
        }

        websocket = MockWebsocketProvider(
            onConnect: onConnect,
            onDisconnect: onDisconnect,
            onWrite: onWrite
        )

        // Retain the provider so it doesn't release prior to executing callbacks
        let provider = createProviderAndConnect(listeners: ["1", "2", "3", "4"])

        wait(
            for: [receivedInProgress, receivedConnected, receivedNotConnected, receivedError],
            timeout: 1
        )

        XCTAssertFalse(provider.listeners.isEmpty)

        let listenersToRemove = provider.listeners.map { $0.key }

        // Removing all the listeners will disconnect the websocket connection
        for identifier in listenersToRemove {
            provider.removeListener(identifier: identifier)
        }

        // Since removing listeners is asynchronous, we have to wait for the disconnect
        wait(for: [receivedDisconnect], timeout: 1)
        XCTAssertTrue(provider.listeners.isEmpty)
        XCTAssertEqual(provider.status, .notConnected)
    }

    /// Provider test
    ///
    /// Given:
    /// - A configured subscriber -> provider -> websocket chain
    /// When:
    /// - I invoke `provider.connect()`
    /// - And the websocket reports a connection error
    /// Then:
    /// - The subscriber is notified of the unsuccessful connection
    func testConnectionError() {
        receivedConnected.isInverted = true
        receivedNotConnected.isInverted = true

        let onConnect: MockWebsocketProvider.OnConnect = { _, _, delegate in
            self.websocketDelegate = delegate
            DispatchQueue.global().async {
                delegate?.websocketDidConnect(provider: self.websocket)
            }
        }

        let onDisconnect: MockWebsocketProvider.OnDisconnect = { }

        let onWrite: MockWebsocketProvider.OnWrite = { message in
            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
                XCTFail("Incoming message did not have 'connection_init' type")
                return
            }

            self.websocketDelegate.websocketDidDisconnect(
                provider: self.websocket,
                error: "test error"
            )
        }

        websocket = MockWebsocketProvider(
            onConnect: onConnect,
            onDisconnect: onDisconnect,
            onWrite: onWrite
        )

        // Retain the provider so it doesn't release prior to executing callbacks
        let provider = createProviderAndConnect()

        // Get rid of "written to, but never read" compiler warnings
        print(provider)

        waitForExpectations(timeout: 0.05)
    }

    /// Stale connection test
    ///
    /// Given:
    /// - A provider configured with a default stale connection timeout
    /// When:
    /// - The service sends a message containing an override timeout value
    /// Then:
    /// - The provider updates its stale connection timeout to the service-provided value
    func testServiceOverridesStaleConnectionTimeout() {
        receivedNotConnected.isInverted = true
        receivedError.isInverted = true

        let expectedTimeoutInSeconds = 60.0
        let timeoutInMilliseconds = Int(expectedTimeoutInSeconds) * 1_000

        let onConnect: MockWebsocketProvider.OnConnect = { _, _, delegate in
            self.websocketDelegate = delegate
            DispatchQueue.global().async {
                delegate?.websocketDidConnect(provider: self.websocket)
            }
        }

        let onDisconnect: MockWebsocketProvider.OnDisconnect = { }

        let connectionAckMessage = RealtimeConnectionProviderTestBase
            .makeConnectionAckMessage(withTimeout: timeoutInMilliseconds)
        let onWrite: MockWebsocketProvider.OnWrite = { message in
            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
                XCTFail("Incoming message did not have 'connection_init' type")
                return
            }

            self.websocketDelegate.websocketDidReceiveData(
                provider: self.websocket,
                data: connectionAckMessage
            )
        }

        websocket = MockWebsocketProvider(
            onConnect: onConnect,
            onDisconnect: onDisconnect,
            onWrite: onWrite
        )

        let provider = createProviderAndConnect()

        wait(for: [receivedConnected], timeout: 0.05)
        XCTAssertEqual(provider.staleConnectionTimer.interval, expectedTimeoutInSeconds)

        waitForExpectations(timeout: 0.05)
    }

}

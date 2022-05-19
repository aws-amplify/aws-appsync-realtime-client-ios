//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

@available(iOS 13.0, *)
class ConnectionProviderAsyncTests: RealtimeConnectionProviderAsyncTestBase {

    /// Provider test
    ///
    /// Given:
    /// - A configured subscriber -> provider -> websocket chain
    /// When:
    /// - I invoke `provider.connect()`
    /// - And the websocket properly connects
    /// Then:
    /// - The subscriber is notified of the successful connection
    func testSuccessfulConnection() async {
        receivedNotConnected.isInverted = true
        receivedError.isInverted = true

        let onConnect: MockWebsocketProviderAsync.OnConnect = { _, _, delegate in
            self.websocketDelegate = delegate
            Task {
                await delegate?.websocketDidConnect(provider: self.websocket)
            }
        }

        let onDisconnect: MockWebsocketProvider.OnDisconnect = { }

        let onWrite: MockWebsocketProviderAsync.OnWrite = { message in
            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
                XCTFail("Incoming message did not have 'connection_init' type")
                return
            }

            await self.websocketDelegate.websocketDidReceiveData(
                provider: self.websocket,
                data: RealtimeConnectionProviderTestBase.makeConnectionAckMessage()
            )
        }

        websocket = MockWebsocketProviderAsync(
            onConnect: onConnect,
            onDisconnect: onDisconnect,
            onWrite: onWrite
        )

        // Retain the provider so it doesn't release prior to executing callbacks
        let provider = createProviderAndConnect()

        // Get rid of "written to, but never read" compiler warnings
        print(provider)

        await waitForExpectations(timeout: 0.05)
    }

    /// Provider add and remove listeners tests
    ///
    /// Given:
    /// - A connected websocket with a listener
    /// When:
    /// - remove all listeners
    /// Then:
    /// - The listeners are removed and the connection is disconnected
    func testAddRemoveListeners() async throws {
        receivedNotConnected.isInverted = true
        receivedError.isInverted = true

        let onConnect: MockWebsocketProviderAsync.OnConnect = { _, _, delegate in
            self.websocketDelegate = delegate
            Task {
                await delegate?.websocketDidConnect(provider: self.websocket)
            }
        }

        let receivedDisconnect = expectation(description: "receivedDisconnect")
        let onDisconnect: MockWebsocketProvider.OnDisconnect = {
            receivedDisconnect.fulfill()
        }

        let onWrite: MockWebsocketProviderAsync.OnWrite = { message in
            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
                XCTFail("Incoming message did not have 'connection_init' type")
                return
            }

            await self.websocketDelegate.websocketDidReceiveData(
                provider: self.websocket,
                data: RealtimeConnectionProviderTestBase.makeConnectionAckMessage()
            )
        }

        websocket = MockWebsocketProviderAsync(
            onConnect: onConnect,
            onDisconnect: onDisconnect,
            onWrite: onWrite
        )

        // Retain the provider so it doesn't release prior to executing callbacks
        let provider = createProviderAndConnect(listeners: ["1", "2", "3", "4"])

//        wait(
//            for: [receivedInProgress, receivedConnected, receivedNotConnected, receivedError],
//            timeout: 50
//        )
        receivedDisconnect.isInverted = true
        await waitForExpectations(timeout: 1)

        var isListenersEmpty = await provider.listeners.isEmpty
        XCTAssertFalse(isListenersEmpty)

        let listenersToRemove = await provider.listeners.map { $0.key }

        // Removing all the listeners will disconnect the websocket connection
        for identifier in listenersToRemove {
            provider.removeListener(identifier: identifier)
        }

        // Since removing listeners is asynchronous, we have to wait for the disconnect
        // wait(for: [receivedDisconnect], timeout: 1)
        // There's currently a bug that prevents wait(for:...) from working with Swift Concurrency
        // The following line is a workaround that should be changed once this is fixed.
        try await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))

        isListenersEmpty = await provider.listeners.isEmpty
        XCTAssertTrue(isListenersEmpty)

        let status = await provider.status
        XCTAssertEqual(status, .notConnected)
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

        let onConnect: MockWebsocketProviderAsync.OnConnect = { _, _, delegate in
            self.websocketDelegate = delegate
            Task {
                await delegate?.websocketDidConnect(provider: self.websocket)
            }
        }

        let onDisconnect: MockWebsocketProvider.OnDisconnect = { }

        let onWrite: MockWebsocketProviderAsync.OnWrite = { message in
            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
                XCTFail("Incoming message did not have 'connection_init' type")
                return
            }

            await self.websocketDelegate.websocketDidDisconnect(
                provider: self.websocket,
                error: "test error"
            )
        }

        websocket = MockWebsocketProviderAsync(
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
    func testServiceOverridesStaleConnectionTimeout() async {
        receivedNotConnected.isInverted = true
        receivedError.isInverted = true

        let expectedTimeoutInSeconds = 60.0
        let timeoutInMilliseconds = Int(expectedTimeoutInSeconds) * 1_000

        let onConnect: MockWebsocketProviderAsync.OnConnect = { _, _, delegate in
            self.websocketDelegate = delegate
            Task {
                await delegate?.websocketDidConnect(provider: self.websocket)
            }
        }

        let onDisconnect: MockWebsocketProvider.OnDisconnect = { }

        let connectionAckMessage = RealtimeConnectionProviderTestBase
            .makeConnectionAckMessage(withTimeout: timeoutInMilliseconds)
        let onWrite: MockWebsocketProviderAsync.OnWrite = { message in
            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
                XCTFail("Incoming message did not have 'connection_init' type")
                return
            }

            await self.websocketDelegate.websocketDidReceiveData(
                provider: self.websocket,
                data: connectionAckMessage
            )
        }

        websocket = MockWebsocketProviderAsync(
            onConnect: onConnect,
            onDisconnect: onDisconnect,
            onWrite: onWrite
        )

        let provider = createProviderAndConnect()

        await waitForExpectations(timeout: 0.05)

        let staleConnectionInterval = await provider.staleConnectionTimer.interval
        XCTAssertEqual(staleConnectionInterval, expectedTimeoutInSeconds)
    }

}

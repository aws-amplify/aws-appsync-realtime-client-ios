//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

class ConnectionProviderStaleConnectionTests: RealtimeConnectionProviderTestBase {

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

    /// Given a connected websocket, when the network status toggles to disconnected and back to connected,
    /// the connecion should be disconnected with `error`.
    /// Note: This error is handled by the subscriptions to attempt to reconnect the websocket.
    ///
    /// - Given: Connected websocket
    /// - When:
    ///    - Connectivity updates to unsatisfied (network is down)
    ///    - Connectivity updates to satisfied (network is back up)
    /// - Then:
    ///    - Websocket is disconnected
    func testConnectionDisconnectsAfterConnectivityUpdates() {
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
        let connectionQueue = DispatchQueue(
            label: "com.amazonaws.ConnectionProviderStaleConnectionTests.connectionQueue")

        let monitor = MockConnectivityMonitor()
        let connectivityMonitor = ConnectivityMonitor(monitor: monitor)

        // Retain the provider so it doesn't release prior to executing callbacks
        let provider = createProviderAndConnect(
            listeners: nil,
            connectionQueue: connectionQueue,
            connectivityMonitor: connectivityMonitor
        )

        // Wait for websocket to be connected
        waitForExpectations(timeout: 0.05)

        // Send connectivity update - network down
        monitor.sendConnectivityUpdate(.init(status: .unsatisfied))
        let connectionIsStale = expectation(description: "connection is stale")
        connectionQueue.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(provider.isStaleConnection)
            connectionIsStale.fulfill()
        }
        wait(for: [connectionIsStale], timeout: 1.0)

        // Send connectivity update - network up
        let receivedError = expectation(description: "listeners receive error event")
        provider.addListener(identifier: "id") { event in
            guard case .error = event else {
                XCTFail("Event should be error")
                return
            }
            receivedError.fulfill()
        }
        monitor.sendConnectivityUpdate(.init(status: .satisfied))
        let connectionIsDisconnected = expectation(description: "connection is disconnected")
        connectionQueue.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(provider.isStaleConnection)
            XCTAssertTrue(provider.status == .notConnected)
            connectionIsDisconnected.fulfill()
        }
        wait(for: [connectionIsDisconnected, receivedError], timeout: 1.0)
    }
}

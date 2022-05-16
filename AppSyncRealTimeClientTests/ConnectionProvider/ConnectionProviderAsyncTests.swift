//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

#if swift(>=5.5.2)
@available(iOS 13.0, *)
class ConnectionProviderAsyncTests: XCTestCase { // }: RealtimeConnectionProviderAsyncTestBase {

    func test() async {
        print("ok")

        await waitForExpectations(timeout: 3)
    }

}

    /// Provider test
    ///
    /// Given:
    /// - A configured subscriber -> provider -> websocket chain
    /// When:
    /// - I invoke `provider.connect()`
    /// - And the websocket properly connects
    /// Then:
    /// - The subscriber is notified of the successful connection
//    func testSuccessfulConnection() async {
//        await expectations.invertReceivedNotConnected()
//        await expectations.invertReceivedError()

//        let receivedInProgress = expectations.receivedInProgress
//        let receivedConnected = expectations.receivedConnected

//        let expectation = expectation(description: "blah")
//        await expectations.setExpectations(
//            receivedInProgress: expectation,
//            receivedConnected: expectation,
//            receivedNotConnected: expectation,
//            receivedError: expectation
//        )

//        let onConnect: MockWebsocketProviderAsync.OnConnect = { _, _, delegate in
//            self.websocketDelegate = delegate
////            Task {
//                await delegate?.websocketDidConnect(provider: self.websocket)
////            }
//        }
//
//        let onDisconnect: MockWebsocketProviderAsync.OnDisconnect = { }
//
//        let onWrite: MockWebsocketProviderAsync.OnWrite = { message in
//            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
//                XCTFail("Incoming message did not have 'connection_init' type")
//                return
//            }
//
//            await self.websocketDelegate.websocketDidReceiveData(
//                provider: self.websocket,
//                data: RealtimeConnectionProviderTestBase.makeConnectionAckMessage()
//            )
//        }
//
//        websocket = MockWebsocketProviderAsync(
//            onConnect: onConnect,
//            onDisconnect: onDisconnect,
//            onWrite: onWrite
//        )

        // Retain the provider so it doesn't release prior to executing callbacks
//        let provider = await createProviderAndConnect()

        // Get rid of "written to, but never read" compiler warnings
//        print(provider)

        //await waitForExpectations(timeout: 20.05)
//        wait(for: [expectations.receivedConnected], timeout: 5.05)
    //}

    /// Provider add and remove listeners tests
    ///
    /// Given:
    /// - A connected websocket with a listener
    /// When:
    /// - remove all listeners
    /// Then:
    /// - The listeners are removed and the connection is disconnected
//    func testAddRemoveListeners() async {
//        await expectations.invertReceivedNotConnected()
//        await expectations.invertReceivedError()
//
//        let onConnect: MockWebsocketProviderAsync.OnConnect = { _, _, delegate in
//            self.websocketDelegate = delegate
//            Task {
//                await delegate?.websocketDidConnect(provider: self.websocket)
//            }
//        }
//
//        let receivedDisconnect = expectation(description: "receivedDisconnect")
//        let onDisconnect: MockWebsocketProviderAsync.OnDisconnect = {
//            receivedDisconnect.fulfill()
//        }
//
//        let onWrite: MockWebsocketProviderAsync.OnWrite = { message in
//            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
//                XCTFail("Incoming message did not have 'connection_init' type")
//                return
//            }
//
//            await self.websocketDelegate.websocketDidReceiveData(
//                provider: self.websocket,
//                data: RealtimeConnectionProviderTestBase.makeConnectionAckMessage()
//            )
//        }
//
//        websocket = MockWebsocketProviderAsync(
//            onConnect: onConnect,
//            onDisconnect: onDisconnect,
//            onWrite: onWrite
//        )
//
//        // Retain the provider so it doesn't release prior to executing callbacks
//        let provider = await createProviderAndConnect(listeners: ["1", "2", "3", "4"])
//
//        wait(
//            for: [receivedInProgress, receivedConnected, receivedNotConnected, receivedError],
//            timeout: 1
//        )
//
//        var listenersEmpty = await provider.listeners.isEmpty
//        XCTAssertFalse(listenersEmpty)
//
//        let listenersToRemove = await provider.listeners.map { $0.key }
//
//        // Removing all the listeners will disconnect the websocket connection
//        for identifier in listenersToRemove {
//            await provider.removeListener(identifier: identifier)
//        }
//
//        // Since removing listeners is asynchronous, we have to wait for the disconnect
//        // wait(for: [receivedDisconnect], timeout: 1)
//        listenersEmpty = await provider.listeners.isEmpty
//        XCTAssertTrue(listenersEmpty)
//
//        let status = await provider.status
//        XCTAssertEqual(status, .notConnected)
//    }
//
//    /// Provider test
//    ///
//    /// Given:
//    /// - A configured subscriber -> provider -> websocket chain
//    /// When:
//    /// - I invoke `provider.connect()`
//    /// - And the websocket reports a connection error
//    /// Then:
//    /// - The subscriber is notified of the unsuccessful connection
//    func testConnectionError() async {
//        receivedConnected.isInverted = true
//        receivedNotConnected.isInverted = true
//
//        let onConnect: MockWebsocketProviderAsync.OnConnect = { _, _, delegate in
//            self.websocketDelegate = delegate
//            // DispatchQueue.global().async {
//            await delegate?.websocketDidConnect(provider: self.websocket)
//            // }
//        }
//
//        let onDisconnect: MockWebsocketProviderAsync.OnDisconnect = { }
//
//        let onWrite: MockWebsocketProviderAsync.OnWrite = { message in
//            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
//                XCTFail("Incoming message did not have 'connection_init' type")
//                return
//            }
//
//            await self.websocketDelegate.websocketDidDisconnect(
//                provider: self.websocket,
//                error: "test error"
//            )
//        }
//
//        websocket = MockWebsocketProviderAsync(
//            onConnect: onConnect,
//            onDisconnect: onDisconnect,
//            onWrite: onWrite
//        )
//
//        // Retain the provider so it doesn't release prior to executing callbacks
//        let provider = await createProviderAndConnect()
//
//        // Get rid of "written to, but never read" compiler warnings
//        print(provider)
//
//        await waitForExpectations(timeout: 0.05)
//    }
//
//    /// Stale connection test
//    ///
//    /// Given:
//    /// - A provider configured with a default stale connection timeout
//    /// When:
//    /// - The service sends a message containing an override timeout value
//    /// Then:
//    /// - The provider updates its stale connection timeout to the service-provided value
//    func testServiceOverridesStaleConnectionTimeout() async {
//        receivedNotConnected.isInverted = true
//        receivedError.isInverted = true
//
//        let expectedTimeoutInSeconds = 60.0
//        let timeoutInMilliseconds = Int(expectedTimeoutInSeconds) * 1_000
//
//        let onConnect: MockWebsocketProviderAsync.OnConnect = { _, _, delegate in
//            self.websocketDelegate = delegate
//            Task {
//                await delegate?.websocketDidConnect(provider: self.websocket)
//            }
//        }
//
//        let onDisconnect: MockWebsocketProviderAsync.OnDisconnect = { }
//
//        let connectionAckMessage = RealtimeConnectionProviderTestBase
//            .makeConnectionAckMessage(withTimeout: timeoutInMilliseconds)
//        let onWrite: MockWebsocketProviderAsync.OnWrite = { message in
//            guard RealtimeConnectionProviderTestBase.messageType(of: message, equals: "connection_init") else {
//                XCTFail("Incoming message did not have 'connection_init' type")
//                return
//            }
//
//            await self.websocketDelegate.websocketDidReceiveData(
//                provider: self.websocket,
//                data: connectionAckMessage
//            )
//        }
//
//        websocket = MockWebsocketProviderAsync(
//            onConnect: onConnect,
//            onDisconnect: onDisconnect,
//            onWrite: onWrite
//        )
//
//        let provider = await createProviderAndConnect()
//
//        wait(for: [receivedConnected], timeout: 0.05)
//
//        let staleConnectionTimerInterval = await provider.staleConnectionTimer.interval
//        XCTAssertEqual(staleConnectionTimerInterval, expectedTimeoutInSeconds)
//
//        await waitForExpectations(timeout: 0.05)
//    }

//}
#endif

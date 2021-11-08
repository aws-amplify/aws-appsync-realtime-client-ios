//
// Copyright 2018-2021 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
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
        XCTAssertEqual(provider.staleConnectionTimeout.get(), expectedTimeoutInSeconds)

        waitForExpectations(timeout: 0.05)
    }

}

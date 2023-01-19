//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

class RealtimeConnectionProviderAsyncTestBase: XCTestCase {

    let urlRequest = URLRequest(url: URL(string: "https://www.appsyncrealtimeclient.test/")!)

    var websocket: MockWebsocketProvider!

    // swiftlint:disable:next weak_delegate
    var websocketDelegate: AppSyncWebsocketDelegate!

    // Shared test expectations. Set expected fulfillment counts and inversions as
    // needed in the body of the test.
    var receivedInProgress: XCTestExpectation!
    var receivedConnected: XCTestExpectation!
    var receivedNotConnected: XCTestExpectation!
    var receivedError: XCTestExpectation!

    override func setUp() {
        receivedInProgress = expectation(description: "receivedInProgress")
        receivedConnected = expectation(description: "receivedConnected")
        receivedNotConnected = expectation(description: "receivedNotConnected")
        receivedError = expectation(description: "receivedError")
    }

    // MARK: - Utilities

    /// Creates a RealtimeConnectionProvider, adds a listener that fulfills the shared
    /// expectations as appropriate, and invokes `connect()`. Returns the provider for
    /// subsequent testing.
    ///
    /// Preconditions:
    /// - `self.websocket` must be initialized in the mock provider's `onConnect`
    func createProviderAndConnect(
        listeners: [String]? = nil,
        serialCallbackQueue: DispatchQueue = DispatchQueue(
            label: "com.amazonaws.RealtimeConnectionProviderTestBase.serialCallbackQueue"
        ),
        connectivityMonitor: ConnectivityMonitor = ConnectivityMonitor()
    ) -> RealtimeConnectionProvider {
        let provider = RealtimeConnectionProvider(
            urlRequest: urlRequest,
            websocket: websocket,
            serialCallbackQueue: serialCallbackQueue,
            connectivityMonitor: connectivityMonitor
        )
        provider.addListener(identifier: "testListener") { event in
            switch event {
            case .connection(let connectionState):
                switch connectionState {
                case .inProgress:
                    self.receivedInProgress.fulfill()
                case .connected:
                    self.receivedConnected.fulfill()
                case .notConnected:
                    self.receivedNotConnected.fulfill()
                }
            case .error:
                self.receivedError.fulfill()
            default:
                break
            }
        }
        if let listeners = listeners {
            listeners.forEach { identifier in
                provider.addListener(identifier: identifier) { _ in }
            }
        }
        provider.connect()
        return provider
    }

    /// Given a Stringified AppSyncMessage, validates the `type` is equal to `expectedType`
    /// - Parameter message: a string representation of a websocket message
    /// - Parameter expectedType: the expected value of the type
    /// - Returns: type `type` field of the message, if present
    static func messageType(of message: String, equals expectedType: String) -> Bool {
        guard
            let messageData = message.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: messageData) as? [String: String]
            else {
                return false
        }

        guard let type = dict["type"] else {
            return false
        }

        return type == expectedType
    }

    /// Creates a connection acknowledgement message with the specified timeout
    /// - Parameter timeout: stale connection timeout, in milliseconds (defaults to 300,000)
    static func makeConnectionAckMessage(withTimeout timeout: Int = 300_000) -> Data {
        #"{"type":"connection_ack","payload":{"connectionTimeoutMs":\#(timeout)}}"#
            .data(using: .utf8)!
    }

}

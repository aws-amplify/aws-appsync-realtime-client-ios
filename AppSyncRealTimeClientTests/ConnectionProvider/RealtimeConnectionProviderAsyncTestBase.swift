//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

////
//// Copyright Amazon.com Inc. or its affiliates.
//// All Rights Reserved.
////
//// SPDX-License-Identifier: Apache-2.0
////
//
//import XCTest
//@testable import AppSyncRealTimeClient
//
//#if swift(>=5.5.2)
//
//@available(iOS 13.0.0, *)
//actor AsyncExpectations {
////    var receivedInProgress = XCTestExpectation(description: "receivedInProgress")
//    var receivedConnected = XCTestExpectation(description: "receivedConnected")
////    var receivedNotConnected = XCTestExpectation(description: "receivedNotConnected")
////    var receivedError = XCTestExpectation(description: "receivedError")
//
//    func setExpectations(
//        //        receivedInProgress: XCTestExpectation,
//        receivedConnected: XCTestExpectation
////        receivedNotConnected: XCTestExpectation,
////        receivedError: XCTestExpectation
//    ) {
////        self.receivedInProgress = receivedInProgress
//        self.receivedConnected = receivedConnected
////        self.receivedNotConnected = receivedNotConnected
////        self.receivedError = receivedError
//    }
//
////    func invertReceivedInProgress() {
////        receivedInProgress.isInverted = true
////    }
//
//    func invertReceivedConnected() {
//        receivedConnected.isInverted = true
//    }
//
////    func invertReceivedNotConnected() {
////        receivedNotConnected.isInverted = true
////    }
//
////    func invertReceivedError() {
////        receivedError.isInverted = true
////    }
//}
//
//@available(iOS 13.0, *)
//class RealtimeConnectionProviderAsyncTestBase: XCTestCase {
//
//    let url = URL(string: "https://www.appsyncrealtimeclient.test/")!
//
//    var websocket: MockWebsocketProviderAsync!
//
//    // swiftlint:disable:next weak_delegate
//    var websocketDelegate: AppSyncWebsocketDelegateAsync!
//
//    // Shared test expectations. Set expected fulfillment counts and inversions as
//    // needed in the body of the test.
//    let expectations = AsyncExpectations()
//
//    override func setUp() async throws {
////        let receivedInProgress = expectation(description: "receivedInProgress")
//     //   let receivedConnected = expectation(description: "receivedConnected")
////        let receivedNotConnected = expectation(description: "receivedNotConnected")
////        let receivedError = expectation(description: "receivedError")
//
//       // await expectations.setExpectations(
//            //            receivedInProgress: receivedInProgress,
//      //      receivedConnected: receivedConnected
////            receivedNotConnected: receivedNotConnected,
////            receivedError: receivedError
//       // )
//    }
//
//    // MARK: - Utilities
//
//    /// Creates a RealtimeConnectionProvider, adds a listener that fulfills the shared
//    /// expectations as appropriate, and invokes `connect()`. Returns the provider for
//    /// subsequent testing.
//    ///
//    /// Preconditions:
//    /// - `self.websocket` must be initialized in the mock provider's `onConnect`
//    func createProviderAndConnect(
//        listeners: [String]? = nil,
//        connectivityMonitor: ConnectivityMonitor = ConnectivityMonitor()
//    ) async -> RealtimeConnectionProviderAsync {
//        let provider = await RealtimeConnectionProviderAsync(
//            url: url,
//            websocket: websocket,
//            connectivityMonitor: connectivityMonitor
//        )
//        await provider.addListener(identifier: "testListener") { event in
//            switch event {
//            case .connection(let connectionState):
//                switch connectionState {
//                case .inProgress:
//                    print("ok")
////                    await self.expectations.receivedInProgress.fulfill()
//                case .connected:
//                    print("ok")
//                    //await self.expectations.receivedConnected.fulfill()
//                case .notConnected:
//                    print("ok")
////                    await self.expectations.receivedNotConnected.fulfill()
//                }
//            case .error:
//                print("ok")
////                await self.expectations.receivedError.fulfill()
//            default:
//                break
//            }
//        }
////        if let listeners = listeners {
////            for listener in listeners {
////                await provider.addListener(identifier: listener)  { _ in }
////            }
////        }
//        await provider.connect()
//        return provider
//    }
//
//    /// Given a Stringified AppSyncMessage, validates the `type` is equal to `expectedType`
//    /// - Parameter message: a string representation of a websocket message
//    /// - Parameter expectedType: the expected value of the type
//    /// - Returns: type `type` field of the message, if present
////    static func messageType(of message: String, equals expectedType: String) -> Bool {
////        guard
////            let messageData = message.data(using: .utf8),
////            let dict = try? JSONSerialization.jsonObject(with: messageData) as? [String: String]
////            else {
////                return false
////        }
////
////        guard let type = dict["type"] else {
////            return false
////        }
////
////        return type == expectedType
////    }
////
////    /// Creates a connection acknowledgement message with the specified timeout
////    /// - Parameter timeout: stale connection timeout, in milliseconds (defaults to 300,000)
////    static func makeConnectionAckMessage(withTimeout timeout: Int = 300_000) -> Data {
////        #"{"type":"connection_ack","payload":{"connectionTimeoutMs":\#(timeout)}}"#
////            .data(using: .utf8)!
////    }
//
//}
//#endif

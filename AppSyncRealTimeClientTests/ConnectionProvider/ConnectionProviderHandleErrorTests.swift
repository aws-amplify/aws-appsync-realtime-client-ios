//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

class ConnectionProviderHandleErrorTests: XCTestCase {
    let urlRequest = URLRequest(url: URL(string: "https://www.appsyncrealtimeclient.test/")!)
    var websocket = MockWebsocketProvider()

    /// Error response is limit exceeded with id
    /// Should receive ConnectionProviderError.limitExceeded with id
    func testLimitExceededWithId() {
        let provider = RealtimeConnectionProvider(urlRequest: urlRequest, websocket: websocket)

        let subscriptionEvent = expectation(description: "Receieved subscription event")
        provider.addListener(identifier: "id") { event in
            guard case .error(let error) = event,
                  let connectionError = error as? ConnectionProviderError else {
                      XCTFail("Should have received error event")
                      return
            }
            guard case .limitExceeded(let id) = connectionError else {
                XCTFail("Should have received .limitExceeded error")
                return
            }
            XCTAssertEqual(id, "id")
            subscriptionEvent.fulfill()
        }
        let payload = ["errors": AppSyncJSONValue.object(["errorType": "LimitExceededError"])]
        let response = RealtimeConnectionProviderResponse.init(id: "id", payload: payload, type: .error)

        provider.handleError(response: response)
        wait(for: [subscriptionEvent], timeout: 1)
    }

    /// Error response is limit exceeded (connection level error without subscription id)
    /// Should throttle and receive a fraction of ConnectionProviderError.limitExceeded event without id
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testLimitExceededMissingIdThrottled() {
        let provider = RealtimeConnectionProvider(urlRequest: urlRequest, websocket: websocket)
        let limitExceededThrottle = expectation(description: "received limit exceeded")
        limitExceededThrottle.expectedFulfillmentCount = 100
        let sink = provider.limitExceededSubject.sink { error in
            guard case .limitExceeded(let id) = error else {
                XCTFail("Should have received .limitExceeded error")
                return
            }
            XCTAssertNil(id)
            limitExceededThrottle.fulfill()
        }
        let subscriptionEvent = expectation(description: "Receieved subscription event")
        subscriptionEvent.assertForOverFulfill = false
        var subscriptionEventCount = 0
        provider.addListener(identifier: "id") { event in
            guard case .error(let error) = event,
                  let connectionError = error as? ConnectionProviderError else {
                      XCTFail("Should have received error event")
                      return
            }
            guard case .limitExceeded(let id) = connectionError else {
                XCTFail("Should have received .limitExceeded error")
                return
            }
            XCTAssertNil(id)
            subscriptionEventCount += 1
            subscriptionEvent.fulfill()
        }
        let payload = ["errors": AppSyncJSONValue.object(["errorType": "LimitExceededError"])]
        let response = RealtimeConnectionProviderResponse.init(id: nil, payload: payload, type: .error)

        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            provider.handleError(response: response)
        }

        wait(for: [subscriptionEvent, limitExceededThrottle], timeout: 1)
        // The number of subscription events received should be a fraction of the number of throttled events (100)
        XCTAssertTrue(subscriptionEventCount < 10)
        sink.cancel()
    }

    /// Error response is max subscription with subscription id
    /// Should receive ConnectionProviderError.limitExceeded with id
    func testMaxSubscriptionReached() {
        let provider = RealtimeConnectionProvider(urlRequest: urlRequest, websocket: websocket)

        let subscriptionEvent = expectation(description: "Receieved subscription event")
        provider.addListener(identifier: "id") { event in
            guard case .error(let error) = event,
                  let connectionError = error as? ConnectionProviderError else {
                      XCTFail("Should have received error event")
                      return
            }
            guard case .limitExceeded(let id) = connectionError else {
                XCTFail("Should have received .limitExceeded error")
                return
            }
            XCTAssertEqual(id, "id")
            subscriptionEvent.fulfill()
        }
        let payload = ["errors": AppSyncJSONValue.object(["errorType": "MaxSubscriptionsReachedError"])]
        let response = RealtimeConnectionProviderResponse.init(id: "id", payload: payload, type: .error)

        provider.handleError(response: response)
        wait(for: [subscriptionEvent], timeout: 1)
    }

    /// Error response with no indication for which subscription and missing payload
    /// Should receive ConnectionProviderError.other
    func testMissingId() throws {
        let provider = RealtimeConnectionProvider(urlRequest: urlRequest, websocket: websocket)

        let subscriptionEvent = expectation(description: "Receieved subscription event")
        provider.addListener(identifier: "id") { event in
            guard case .error(let error) = event,
                  let connectionError = error as? ConnectionProviderError else {
                      XCTFail("Should have received error event")
                      return
            }
            guard case .unknown = connectionError else {
                XCTFail("Should have received .unknown error")
                return
            }

            subscriptionEvent.fulfill()
        }
        let response = RealtimeConnectionProviderResponse.init(id: nil, payload: nil, type: .error)

        provider.handleError(response: response)
        wait(for: [subscriptionEvent], timeout: 1)
    }

    /// Error response subscription id and payload
    /// Should receive ConnectionProviderError.subscription(id, payload)
    func testWithSubscriptionId() throws {
        let provider = RealtimeConnectionProvider(urlRequest: urlRequest, websocket: websocket)

        let subscriptionEvent = expectation(description: "Receieved subscription event")
        provider.addListener(identifier: "id") { event in
            guard case .error(let error) = event,
                  let connectionError = error as? ConnectionProviderError else {
                      XCTFail("Should have received error event")
                      return
            }
            guard case .subscription(let id, let payload) = connectionError else {
                XCTFail("Should have received .subscription error")
                return
            }
            XCTAssertEqual(id, "id")
            XCTAssertNotNil(payload)
            subscriptionEvent.fulfill()
        }
        let response = RealtimeConnectionProviderResponse.init(
            id: "id",
            payload: ["errorType": "SomeError"],
            type: .error
        )

        provider.handleError(response: response)
        wait(for: [subscriptionEvent], timeout: 1)
    }
}

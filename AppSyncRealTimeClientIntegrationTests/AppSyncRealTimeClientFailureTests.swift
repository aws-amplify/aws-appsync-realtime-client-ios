//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

class AppSyncRealTimeClientFailureTests: AppSyncRealTimeClientTestBase {

    /// Test the current AppSync limit of 100 subscriptions per connection
    func testMaxSubscriptionReached() { // swiftlint:disable:this cyclomatic_complexity
        let subscribeSuccess = expectation(description: "subscribe successfully")
        subscribeSuccess.expectedFulfillmentCount = 100
        let authInterceptor = APIKeyAuthInterceptor(apiKey)
        let connectionProvider = ConnectionProviderFactory.createConnectionProvider(
            for: urlRequest,
            authInterceptor: authInterceptor,
            connectionType: .appSyncRealtime
        )
        var subscriptions = [AppSyncSubscriptionConnection]()
        for _ in 1 ... 100 {
            let subscription = AppSyncSubscriptionConnection(provider: connectionProvider)
            _ = subscription.subscribe(
                requestString: requestString,
                variables: nil
            ) { event, _ in
                switch event {
                case .connection(let subscriptionConnectionEvent):
                    switch subscriptionConnectionEvent {
                    case .connecting:
                        break
                    case .connected:
                        subscribeSuccess.fulfill()
                    case .disconnected:
                        break
                    }
                case .data(let data):
                    print("Got data back \(data)")
                case .failed(let error):
                    XCTFail("Got error \(error)")
                }
            }
            subscriptions.append(subscription)
        }

        wait(for: [subscribeSuccess], timeout: TestCommonConstants.networkTimeout)
        XCTAssertEqual(subscriptions.count, 100)
        let limitExceeded = expectation(description: "Received Limit Exceeded error")
        let subscription = AppSyncSubscriptionConnection(provider: connectionProvider)
        _ = subscription.subscribe(
            requestString: requestString,
            variables: nil
        ) { event, _ in
            switch event {
            case .connection(let subscriptionConnectionEvent):
                switch subscriptionConnectionEvent {
                case .connecting:
                    break
                case .connected:
                    XCTFail("Got connected successfully - Should have been limit exceeded")
                case .disconnected:
                    break
                }
            case .data(let data):
                print("Got data back \(data)")
            case .failed(let error):
                guard let connectionError = error as? ConnectionProviderError,
                      case .limitExceeded = connectionError else {
                          XCTFail("Should Be Limited Exceeded error")
                          return
                }

                limitExceeded.fulfill()
            }
        }
        wait(for: [limitExceeded], timeout: TestCommonConstants.networkTimeout)

        for subscription in subscriptions {
            if let item = subscription.subscriptionItem {
                subscription.unsubscribe(item: item)
            }
        }
    }

    /// Subscriptions receiving a failed event should only receive it once.
    func testMaxSubscriptionReachedWithRetry() { // swiftlint:disable:this cyclomatic_complexity
        let subscribeSuccess = expectation(description: "subscribe successfully")
        subscribeSuccess.expectedFulfillmentCount = 100
        let authInterceptor = APIKeyAuthInterceptor(apiKey)
        let connectionProvider = ConnectionProviderFactory.createConnectionProvider(
            for: urlRequest,
            authInterceptor: authInterceptor,
            connectionType: .appSyncRealtime
        )
        var subscriptions = [AppSyncSubscriptionConnection]()
        for _ in 1 ... 100 {
            let subscription = AppSyncSubscriptionConnection(provider: connectionProvider)
            _ = subscription.subscribe(
                requestString: requestString,
                variables: nil
            ) { event, _ in
                switch event {
                case .connection(let subscriptionConnectionEvent):
                    switch subscriptionConnectionEvent {
                    case .connecting:
                        break
                    case .connected:
                        subscribeSuccess.fulfill()
                    case .disconnected:
                        break
                    }
                case .data(let data):
                    print("Got data back \(data)")
                case .failed(let error):
                    XCTFail("Got error \(error)")
                }
            }
            subscriptions.append(subscription)
        }

        wait(for: [subscribeSuccess], timeout: TestCommonConstants.networkTimeout)
        XCTAssertEqual(subscriptions.count, 100)
        let limitExceeded = expectation(description: "Received Limit Exceeded error")
        limitExceeded.expectedFulfillmentCount = 2
        for _ in 1 ... 2 {
            let subscription = AppSyncSubscriptionConnection(provider: connectionProvider)
            subscription.addRetryHandler(handler: TestConnectionRetryHandler())
            _ = subscription.subscribe(
                requestString: requestString,
                variables: nil
            ) { event, _ in
                switch event {
                case .connection(let subscriptionConnectionEvent):
                    switch subscriptionConnectionEvent {
                    case .connecting:
                        break
                    case .connected:
                        XCTFail("Got connected successfully - Should have been limit exceeded")
                    case .disconnected:
                        break
                    }
                case .data(let data):
                    print("Got data back \(data)")
                case .failed(let error):
                    guard let connectionError = error as? ConnectionProviderError,
                          case .limitExceeded = connectionError else {
                              XCTFail("Should Be Limited Exceeded error")
                              return
                    }

                    limitExceeded.fulfill()
                }
            }
            subscriptions.append(subscription)
        }

        wait(for: [limitExceeded], timeout: TestCommonConstants.networkTimeout)

        for subscription in subscriptions {
            if let item = subscription.subscriptionItem {
                subscription.unsubscribe(item: item)
            }
        }
    }

    func testAPIKeyInvalid() {
        apiKey = "invalid"
        let subscribeFailed = expectation(description: "subscribe failed")
        let authInterceptor = APIKeyAuthInterceptor(apiKey)
        let connectionProvider = ConnectionProviderFactory.createConnectionProvider(
            for: urlRequest,
            authInterceptor: authInterceptor,
            connectionType: .appSyncRealtime
        )
        let subscriptionConnection = AppSyncSubscriptionConnection(provider: connectionProvider)
        _ = subscriptionConnection.subscribe(
            requestString: requestString,
            variables: nil
        ) { event, _ in

            switch event {
            case .connection:
                break
            case .data:
                break
            case .failed(let error):
                guard let connectionError = error as? ConnectionProviderError,
                      case .unauthorized = connectionError else {
                          XCTFail("Should be `.unauthorized` error")
                          return
                      }
                subscribeFailed.fulfill()
            }
        }

        wait(for: [subscribeFailed], timeout: TestCommonConstants.networkTimeout)
    }

    class TestConnectionRetryHandler: ConnectionRetryHandler {
        var count: Int = 0
        func shouldRetryRequest(for error: ConnectionProviderError) -> RetryAdvice {
            if count > 10 {
                return TestRetryAdvice(shouldRetry: false)
            }

            if case .limitExceeded = error {
                self.count += 1
                return TestRetryAdvice(shouldRetry: true, retryInterval: .seconds(1))
            }
            return TestRetryAdvice(shouldRetry: false)

        }
    }

    struct TestRetryAdvice: RetryAdvice {
        var shouldRetry: Bool

        var retryInterval: DispatchTimeInterval?
    }
}

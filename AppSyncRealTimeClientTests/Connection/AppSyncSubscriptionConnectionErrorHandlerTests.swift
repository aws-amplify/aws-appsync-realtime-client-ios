//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

// swiftlint:disable:next type_name type_body_length
class AppSyncSubscriptionConnectionErrorHandlerTests: XCTestCase {

    let connectionProvider = MockConnectionProvider()

    let mockRequestString = """
        subscription OnCreateMessage {
            onCreateMessage {
                __typename
                id
                message
                createdAt
            }
        }
        """

    let variables = [String: Any]()

    func testOtherSubscription() throws {
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")
        let failedEvent = expectation(description: "Failed event should not be fired")
        failedEvent.isInverted = true
        let item = connection.subscribe(requestString: mockRequestString, variables: variables) { event, _ in
            switch event {
            case .connection(let status):
                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed:
                failedEvent.fulfill()
                XCTFail("Error should not be thrown")
            }
        }
        XCTAssertNotNil(item, "Subscription item should not be nil")
        wait(for: [connectedMessageExpectation], timeout: 5)
        XCTAssertNotNil(connectionProvider.listener)

        let otherSubscriptionError = ConnectionProviderError.subscription("otherId", nil)
        connection.handleError(error: otherSubscriptionError)
        wait(for: [failedEvent], timeout: 5)
    }

    func testThisSubscription() throws {
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")
        let failedEvent = expectation(description: "Failed event should be fired")
        let item = connection.subscribe(requestString: mockRequestString, variables: variables) { event, _ in
            switch event {
            case .connection(let status):
                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed(let error):
                guard let connection = error as? ConnectionProviderError,
                      case .subscription(let id, _) = connection,
                      !id.isEmpty else {
                          XCTFail("Should be .subscription(item.identifier)")
                          return
                }
                failedEvent.fulfill()
            }
        }
        wait(for: [connectedMessageExpectation], timeout: 5)
        XCTAssertNotNil(connectionProvider.listener)

        let thisSubscriptionError = ConnectionProviderError.subscription(item.identifier, nil)
        connection.handleError(error: thisSubscriptionError)
        wait(for: [failedEvent], timeout: 5)
        XCTAssertNil(connectionProvider.listener)
    }

    func testLimitExceededOtherSubscription() throws {
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")
        let failedEvent = expectation(description: "Failed event should not be fired")
        failedEvent.isInverted = true
        let item = connection.subscribe(requestString: mockRequestString, variables: variables) { event, _ in
            switch event {
            case .connection(let status):
                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed:
                failedEvent.fulfill()
                XCTFail("Error should not be thrown")
            }
        }
        XCTAssertNotNil(item, "Subscription item should not be nil")
        wait(for: [connectedMessageExpectation], timeout: 5)
        XCTAssertNotNil(connectionProvider.listener)

        let limitExceeded = ConnectionProviderError.limitExceeded("otherId")
        connection.handleError(error: limitExceeded)
        wait(for: [failedEvent], timeout: 5)
    }

    func testLimitExceededThisSubscription() throws {
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")
        let failedEvent = expectation(description: "Failed event should be fired")
        let item = connection.subscribe(requestString: mockRequestString, variables: variables) { event, _ in
            switch event {
            case .connection(let status):
                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed(let error):
                guard let connection = error as? ConnectionProviderError,
                      case .limitExceeded(let id) = connection, id != nil else {
                          XCTFail("Should be .limitExceeded(item.identifier)")
                          return
                }
                failedEvent.fulfill()
            }
        }
        wait(for: [connectedMessageExpectation], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .subscribed)
        XCTAssertNotNil(connectionProvider.listener)

        let limitExceeded = ConnectionProviderError.limitExceeded(item.identifier)
        connection.handleError(error: limitExceeded)
        wait(for: [failedEvent], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .notSubscribed)
        XCTAssertNil(connectionProvider.listener)
    }

    func testLimitExceededConnectionLevel_SubscribedShouldNoOp() throws {
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")
        let failedEvent = expectation(description: "Failed event should not be fired")
        failedEvent.isInverted = true
        _ = connection.subscribe(requestString: mockRequestString, variables: variables) { event, _ in
            switch event {
            case .connection(let status):
                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed:
                failedEvent.fulfill()
                XCTFail("Error should not be thrown")
            }
        }
        wait(for: [connectedMessageExpectation], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .subscribed)
        XCTAssertNotNil(connectionProvider.listener)

        let connectionLevelLimitedExceeded = ConnectionProviderError.limitExceeded(nil)
        connection.handleError(error: connectionLevelLimitedExceeded)
        wait(for: [failedEvent], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .subscribed)
        XCTAssertNotNil(connectionProvider.listener)
    }

    func testLimitExceededConnectionLevel_InProgressToNotSubscribed() throws {
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")
        let failedEvent = expectation(description: "Failed event should be fired")
        _ = connection.subscribe(requestString: mockRequestString, variables: variables) { event, _ in
            switch event {
            case .connection(let status):
                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed(let error):
                guard let connection = error as? ConnectionProviderError,
                      case .limitExceeded(let id) = connection,
                      id == nil else {
                          XCTFail("Should be .limitExceeded(nil)")
                          return
                }
                failedEvent.fulfill()
            }
        }
        wait(for: [connectedMessageExpectation], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .subscribed)
        XCTAssertNotNil(connectionProvider.listener)

        connection.subscriptionState = .inProgress

        let connectionLevelLimitedExceeded = ConnectionProviderError.limitExceeded(nil)
        connection.handleError(error: connectionLevelLimitedExceeded)
        wait(for: [failedEvent], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .notSubscribed)
        XCTAssertNil(connectionProvider.listener)
    }

    func testConnection() throws {
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")
        let failedEvent = expectation(description: "Failed event should be fired")
        _ = connection.subscribe(requestString: mockRequestString, variables: variables) { event, _ in
            switch event {
            case .connection(let status):
                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed(let error):
                guard let connection = error as? ConnectionProviderError,
                      case .connection = connection else {
                          XCTFail("Should be .connection")
                          return
                }
                failedEvent.fulfill()
            }
        }
        wait(for: [connectedMessageExpectation], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .subscribed)
        XCTAssertNotNil(connectionProvider.listener)

        let connectionError = ConnectionProviderError.connection
        connection.handleError(error: connectionError)
        wait(for: [failedEvent], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .notSubscribed)
        XCTAssertNil(connectionProvider.listener)
    }

    func testUnknown() throws {
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")
        let failedEvent = expectation(description: "Failed event should be fired")
        _ = connection.subscribe(requestString: mockRequestString, variables: variables) { event, _ in
            switch event {
            case .connection(let status):
                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed(let error):
                guard let connection = error as? ConnectionProviderError,
                      case .unknown = connection else {
                          XCTFail("Should be .unknown")
                          return
                }
                failedEvent.fulfill()
            }
        }
        wait(for: [connectedMessageExpectation], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .subscribed)
        XCTAssertNotNil(connectionProvider.listener)

        let unknownError = ConnectionProviderError.unknown(message: nil, causedBy: nil, payload: nil)
        connection.handleError(error: unknownError)
        wait(for: [failedEvent], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .notSubscribed)
        XCTAssertNil(connectionProvider.listener)
    }

    func testRetry() {
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)
        connection.addRetryHandler(handler: TestConnectionRetryHandler(maxCount: 0))
        let connectedExpectation = expectation(description: "Connected event should be fired")
        let connectedOnRetryExpectation = expectation(description: "Connected event should be fired")
        var connectedOnce = false
        let failedEvent = expectation(description: "Failed event should be fired")
        _ = connection.subscribe(requestString: mockRequestString, variables: variables) { event, _ in
            switch event {
            case .connection(let status):
                if status == .connected {
                    if !connectedOnce {
                        connectedOnce = true
                        connectedExpectation.fulfill()
                    } else {
                        connectedOnRetryExpectation.fulfill()
                    }
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed(let error):
                guard let connection = error as? ConnectionProviderError,
                      case .connection = connection else {
                          XCTFail("Should be .connection")
                          return
                }
                failedEvent.fulfill()
            }
        }
        wait(for: [connectedExpectation], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .subscribed)
        XCTAssertNotNil(connectionProvider.listener)

        let connectionError = ConnectionProviderError.connection
        connection.handleError(error: connectionError)
        wait(for: [connectedOnRetryExpectation], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .subscribed)
        XCTAssertNotNil(connectionProvider.listener)

        connection.handleError(error: connectionError)
        wait(for: [failedEvent], timeout: 5)
        XCTAssertEqual(connection.subscriptionState, .notSubscribed)
        XCTAssertNil(connectionProvider.listener)
    }

    // MARK: - Helpers

    class TestConnectionRetryHandler: ConnectionRetryHandler {
        var count: Int = 0
        let maxCount: Int

        init(maxCount: Int = 10) {
            self.maxCount = maxCount
        }

        func shouldRetryRequest(for error: ConnectionProviderError) -> RetryAdvice {
            if count > maxCount {
                return TestRetryAdvice(shouldRetry: false)
            }

            if case .connection = error {
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

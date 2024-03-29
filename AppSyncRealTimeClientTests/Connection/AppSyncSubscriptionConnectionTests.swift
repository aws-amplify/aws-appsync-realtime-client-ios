//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

class AppSyncSubscriptionConnectionTests: XCTestCase {

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

    /// Test to check if subscription works
    ///
    /// - Given: A valid subscription connection
    /// - When:
    ///    - I invoke `subscribe` on the connection
    /// - Then:
    ///    - I should get back a `connected` event.
    ///
    func testSubscriptionConnection() {
        let connectionProvider = MockConnectionProvider()
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)

        let connectingMessageExpectation = expectation(description: "Connecting event should be fired")
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")

        let item = connection.subscribe(
            requestString: mockRequestString,
            variables: variables
        ) { event, _ in
            switch event {
            case .connection(let status):

                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
                if status == .connecting {
                    connectingMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed:
                XCTFail("Error should not be thrown")
            }
        }
        XCTAssertNotNil(item, "Subscription item should not be nil")
        wait(for: [connectingMessageExpectation, connectedMessageExpectation], timeout: 5, enforceOrder: true)
        XCTAssertNotNil(connectionProvider.listener)
    }

    /// Test unsubscribe subscription gives us back the right events
    ///
    /// - Given: An active subscription connection
    /// - When:
    ///    - I invoke unsubscribe to the connection
    /// - Then:
    ///    - I should get back `disconnected` event back
    ///
    func testUnSubscribeConnection() {
        let connectionProvider = MockConnectionProvider()
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)

        let connectingMessageExpectation = expectation(description: "Connecting event should be fired")
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")
        let unsubscribeAckExpectation = expectation(description: "Not connected event should be fired")
        let item = connection.subscribe(
            requestString: mockRequestString,
            variables: variables
        ) { event, _ in
            switch event {
            case .connection(let status):

                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
                if status == .connecting {
                    connectingMessageExpectation.fulfill()
                }
                if status == .disconnected {
                    unsubscribeAckExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed:
                XCTFail("Error should not be thrown")
            }
        }
        XCTAssertNotNil(item, "Subscription item should not be nil")
        wait(for: [connectingMessageExpectation, connectedMessageExpectation], timeout: 5, enforceOrder: true)

        XCTAssertNotNil(connectionProvider.listener)
        connection.unsubscribe(item: item)
        wait(for: [unsubscribeAckExpectation], timeout: 2)
        XCTAssertNil(connectionProvider.listener)
    }

    /// Test subscription with invalid connection
    ///
    /// - Given: A connection with invalid connection provider
    /// - When:
    ///    - I invoke subscribe
    /// - Then:
    ///    - I should get an error
    ///
    func testInvalidConnection() {
        let connectionProvider = MockConnectionProvider(validConnection: false)
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)

        let connectingMessageExpectation = expectation(description: "Connecting event should be fired")
        let errorEventExpectation = expectation(description: "Error event should be fired")

        let item = connection.subscribe(
            requestString: mockRequestString,
            variables: variables
        ) { event, _ in
            switch event {
            case .connection(let status):

                if status == .connected {
                    XCTFail("Error should not be thrown")
                }
                if status == .connecting {
                    connectingMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Error should not be thrown")
            case .failed:
                errorEventExpectation.fulfill()
            }
        }
        XCTAssertNotNil(item, "Subscription item should not be nil")
        wait(for: [connectingMessageExpectation, errorEventExpectation], timeout: 5, enforceOrder: true)
        XCTAssertNil(connectionProvider.listener)
    }

    /// Test if trying to subscribe with a 'not connected' connection gives error
    ///
    /// - Given: A connection with not invalid connection
    /// - When:
    ///    - I try to subscribe
    /// - Then:
    ///    - I should get an error
    ///
    func testNotConnectedEventDuringSubscribe() {
        let connectionProvider = MockConnectionProviderAlwaysConnect()
        connectionProvider.isConnected = false

        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)

        let connectingMessageExpectation = expectation(description: "Connecting event should be fired")
        let errorEventExpectation = expectation(description: "Error event should be fired")

        let item = connection.subscribe(
            requestString: mockRequestString,
            variables: variables
        ) { event, _ in
            switch event {
            case .connection(let status):

                if status == .connected {
                    XCTFail("Error should not be thrown")
                }
                if status == .connecting {
                    connectingMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed:
                errorEventExpectation.fulfill()
            }
        }
        XCTAssertNotNil(item, "Subscription item should not be nil")
        wait(for: [connectingMessageExpectation, errorEventExpectation], timeout: 5, enforceOrder: true)
        XCTAssertNil(connectionProvider.listener)
    }

    /// Test if valid data is returned
    ///
    /// - Given: A valid connection with subscription connected
    /// - When:
    ///    - When connection provider receive a data message
    /// - Then:
    ///    - I should get back a valid data event
    ///
    func testReceiveValidData() {
        let connectionProvider = MockConnectionProvider()
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)

        let connectingMessageExpectation = expectation(description: "Connecting event should be fired")
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")

        let dataEventExpectation = expectation(description: "Data event should be fired")

        let item = connection.subscribe(
            requestString: mockRequestString,
            variables: variables
        ) { event, _ in
            switch event {
            case .connection(let status):

                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
                if status == .connecting {
                    connectingMessageExpectation.fulfill()
                }
            case .data(let data):
                dataEventExpectation.fulfill()
                XCTAssertNotNil(data, "Data should not be nil")
            case .failed:
                XCTFail("Error should not be thrown")
            }
        }
        XCTAssertNotNil(item, "Subscription item should not be nil")
        wait(for: [connectingMessageExpectation, connectedMessageExpectation], timeout: 5, enforceOrder: true)

        let mockResponse = AppSyncResponse(
            id: item.identifier,
            payload: ["data": "testData"],
            type: .data
        )
        connectionProvider.sendDataResponse(mockResponse)
        wait(for: [dataEventExpectation], timeout: 2)
        XCTAssertNotNil(connectionProvider.listener)
    }

    func testNilDataInVariables() {
        let variablesWithNil = ["key": nil] as [String: Any?]
        let connectionProvider = MockConnectionProvider()
        let connection = AppSyncSubscriptionConnection(provider: connectionProvider)

        let connectingMessageExpectation = expectation(description: "Connecting event should be fired")
        let connectedMessageExpectation = expectation(description: "Connected event should be fired")

        let item = connection.subscribe(
            requestString: mockRequestString,
            variables: variablesWithNil
        ) { event, _ in
            switch event {
            case .connection(let status):

                if status == .connected {
                    connectedMessageExpectation.fulfill()
                }
                if status == .connecting {
                    connectingMessageExpectation.fulfill()
                }
            case .data:
                XCTFail("Data event should not be published")
            case .failed:
                XCTFail("Error should not be thrown")
            }
        }
        XCTAssertNotNil(item, "Subscription item should not be nil")
        wait(for: [connectingMessageExpectation, connectedMessageExpectation], timeout: 5, enforceOrder: true)
        XCTAssertNotNil(connectionProvider.listener)
    }

}

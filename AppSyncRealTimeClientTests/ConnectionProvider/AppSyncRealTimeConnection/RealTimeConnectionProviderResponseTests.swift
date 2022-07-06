//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

class RealTimeConnectionProviderResponseTests: XCTestCase {

    func testIsMaxSubscriptionReached_EmptyPayload() throws {
        let response = RealtimeConnectionProviderResponse(
            id: "id",
            payload: nil,
            type: .error
        )

        XCTAssertFalse(response.isMaxSubscriptionReachedError())
        XCTAssertEqual(response.toConnectionProviderError(connectionState: .connected), .subscription("id", nil))
    }

    func testIsMaxSubscriptionReached_MaxSubscriptionsReachedException() throws {
        let payload = ["errorType": AppSyncJSONValue.string("MaxSubscriptionsReachedException")]
        let response = RealtimeConnectionProviderResponse(
            id: "id",
            payload: payload,
            type: .error
        )

        XCTAssertTrue(response.isMaxSubscriptionReachedError())
        XCTAssertEqual(response.toConnectionProviderError(connectionState: .connected), .limitExceeded("id"))
    }

    func testIsMaxSubscriptionReached_MaxSubscriptionsReachedError() throws {
        let payload = ["errors": AppSyncJSONValue.object(["errorType": "MaxSubscriptionsReachedError"])]
        let response = RealtimeConnectionProviderResponse(
            id: "id",
            payload: payload,
            type: .error
        )

        XCTAssertTrue(response.isMaxSubscriptionReachedError())
        XCTAssertEqual(response.toConnectionProviderError(connectionState: .connected), .limitExceeded("id"))
    }

    func testIsLimitExceeded_EmptyPayload() throws {
        let response = RealtimeConnectionProviderResponse(
            payload: nil,
            type: .error
        )

        XCTAssertFalse(response.isLimitExceededError())
        XCTAssertEqual(
            response.toConnectionProviderError(connectionState: .connected),
            .unknown(message: nil, causedBy: nil, payload: nil)
        )
    }

    func testIsLimitExceeded_LimitExceededError() throws {
        let payload = ["errors": AppSyncJSONValue.object(["errorType": "LimitExceededError"])]
        let response = RealtimeConnectionProviderResponse(
            payload: payload,
            type: .error
        )

        XCTAssertTrue(response.isLimitExceededError())
        XCTAssertEqual(response.toConnectionProviderError(connectionState: .connected), .limitExceeded(nil))
    }

    func testIsUnauthorized_EmptyPayload() throws {
        let response = RealtimeConnectionProviderResponse(
            payload: nil,
            type: .error
        )

        XCTAssertFalse(response.isUnauthorizationError())
        XCTAssertEqual(
            response.toConnectionProviderError(connectionState: .connected),
            .unknown(message: nil, causedBy: nil, payload: nil)
        )
    }

    func testIsUnauthorized_UnauthorizedException() throws {
        let payload = ["errors": AppSyncJSONValue.array([
            ["errorType": "com.amazonaws.deepdish.graphql.auth#UnauthorizedException"]
        ])]
        let response = RealtimeConnectionProviderResponse(
            payload: payload,
            type: .error
        )

        XCTAssertTrue(response.isUnauthorizationError())
        XCTAssertEqual(
            response.toConnectionProviderError(connectionState: .connected),
            .unauthorized
        )
    }
}

extension ConnectionProviderError: Equatable {
    public static func == (lhs: ConnectionProviderError, rhs: ConnectionProviderError) -> Bool {
        switch (lhs, rhs) {
        case (.connection, .connection):
            return true
        case (.jsonParse, .jsonParse):
            return true
        case (.limitExceeded(let id1), .limitExceeded(let id2)):
            return id1 == id2
        case (.subscription(let id1, _), .subscription(let id2, _)):
            return id1 == id2
        case (.unauthorized, .unauthorized):
            return true
        case (.unknown(let message1, _, _), .unknown(let message2, _, _)):
            return message1 == message2
        default:
            return false
        }
    }
}

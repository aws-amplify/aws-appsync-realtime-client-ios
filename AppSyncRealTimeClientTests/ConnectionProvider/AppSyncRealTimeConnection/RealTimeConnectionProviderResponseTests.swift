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
    }

    func testIsMaxSubscriptionReached_MaxSubscriptionsReachedException() throws {
        let payload = ["errorType": AppSyncJSONValue.string("MaxSubscriptionsReachedException")]
        let response = RealtimeConnectionProviderResponse(
            id: "id",
            payload: payload,
            type: .error
        )

        XCTAssertTrue(response.isMaxSubscriptionReachedError())
    }

    func testIsMaxSubscriptionReached_MaxSubscriptionsReachedError() throws {
        let payload = ["errors": AppSyncJSONValue.object(["errorType": "MaxSubscriptionsReachedError"])]
        let response = RealtimeConnectionProviderResponse(
            id: "id",
            payload: payload,
            type: .error
        )

        XCTAssertTrue(response.isMaxSubscriptionReachedError())
    }

    func testIsLimitExceeded_EmptyPayload() throws {
        let response = RealtimeConnectionProviderResponse(
            payload: nil,
            type: .error
        )

        XCTAssertFalse(response.isLimitExceededError())
    }

    func testIsLimitExceeded_LimitExceededError() throws {
        let payload = ["errors": AppSyncJSONValue.object(["errorType": "LimitExceededError"])]
        let response = RealtimeConnectionProviderResponse(
            payload: payload,
            type: .error
        )

        XCTAssertTrue(response.isLimitExceededError())
    }

}

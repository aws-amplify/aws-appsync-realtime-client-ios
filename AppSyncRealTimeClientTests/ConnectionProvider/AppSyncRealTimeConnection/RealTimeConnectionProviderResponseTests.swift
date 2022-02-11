//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AppSyncRealTimeClient

class RealTimeConnectionProviderResponseTests: XCTestCase {

    func testIsMaxSubscriptionReached() throws {
        let payload = ["errors": AppSyncJSONValue.object(["errorType": "MaxSubscriptionsReachedError"])]
        let response = RealtimeConnectionProviderResponse(
            id: "id",
            payload: payload,
            type: .error
        )

        XCTAssertTrue(response.isMaxSubscriptionReachedError())
    }
}

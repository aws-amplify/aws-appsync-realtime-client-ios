//
// Copyright 2018-2021 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct AppSyncURLHelper {

    public static let standardDomainPattern = "^https://\\w{26}.appsync-api.\\w{2}-\\w{2,}-\\d.amazonaws.com/graphql$"
    
    // Check whether the URL is a custom GraphQL domain
    public static func isCustomGraphQLDomain(url : URL) -> Bool {
        return url.absoluteString.range(of: standardDomainPattern,
                                        options: .regularExpression,
                                       range: nil,
                                       locale: nil) == nil
    }
}

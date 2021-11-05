//
// Copyright 2018-2021 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct AppSyncURLHelper {

    public static let standardDomainPattern =
    "^https://\\w{26}.appsync-api.\\w{2}(?:(?:-\\w{2,})+)-\\d.amazonaws.com/graphql$"
    
    // Check whether the provided GraphQL endpoint has standard appsync domain
    public static func hasStandardAppSyncGraphQLDomain(url : URL) -> Bool {
        return url.absoluteString.range(of: standardDomainPattern,
                                        options: [.regularExpression,
                                                  .caseInsensitive],
                                       range: nil,
                                       locale: nil) != nil
    }
}

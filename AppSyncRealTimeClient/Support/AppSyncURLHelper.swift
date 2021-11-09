//
// Copyright 2018-2021 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum AppSyncURLHelper {

    // A standard app sync domain URL would look like
    // https://abcdefghijklmnopqrstuvwxyz.appsync-api.us-west-2.amazonaws.com/graphql
    public static let standardDomainPattern =
    "^https://\\w{26}.appsync-api.\\w{2}(?:(?:-\\w{2,})+)-\\d.amazonaws.com/graphql$"

    // Check whether the provided GraphQL endpoint has standard appsync domain
    public static func isStandardAppSyncGraphQLDomain(url: URL) -> Bool {
        return url.absoluteString.range(
            of: standardDomainPattern,
            options: [
                .regularExpression,
                .caseInsensitive
            ],
            range: nil,
            locale: nil
        ) != nil
    }
}

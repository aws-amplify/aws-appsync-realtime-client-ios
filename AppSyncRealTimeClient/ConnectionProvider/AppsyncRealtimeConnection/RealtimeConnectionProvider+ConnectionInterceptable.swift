//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension RealtimeConnectionProvider: ConnectionInterceptable {

    public func addInterceptor(_ interceptor: ConnectionInterceptor) {
        connectionInterceptors.append(interceptor)
    }

    public func interceptConnection(
        _ request: AppSyncConnectionRequest,
        for endpoint: URL,
        completion: (AppSyncConnectionRequest) -> Void
    ) {

            chainInterceptors(
                index: 0,
                request: request,
                endpoint: endpoint,
                completion: completion
            )
        }

    private func chainInterceptors(
        index: Int,
        request: AppSyncConnectionRequest,
        endpoint: URL,
        completion: (AppSyncConnectionRequest) -> Void
    ) {

            guard index < connectionInterceptors.count else {
                completion(request)
                return
            }
            let interceptor = connectionInterceptors[index]
            interceptor.interceptConnection(request, for: endpoint) { interceptedRequest in
                chainInterceptors(
                    index: index + 1,
                    request: interceptedRequest,
                    endpoint: endpoint,
                    completion: completion
                )
            }
        }

    // MARK: Deprecated method

    public func interceptConnection(
        _ request: AppSyncConnectionRequest,
        for endpoint: URL
    ) -> AppSyncConnectionRequest {
        fatalError("Should not be invoked, use the callback based api")
    }
}

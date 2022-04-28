//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

@available(iOS 13.0.0, *)
extension RealtimeConnectionProviderAsync: ConnectionInterceptableAsync {

    public func addInterceptor(_ interceptor: ConnectionInterceptorAsync) {
        useAsyncInterceptors = true
        connectionInterceptors.append(interceptor)
    }

    public func interceptConnection(_ request: AppSyncConnectionRequest, for endpoint: URL) async -> AppSyncConnectionRequest {
        guard let connectionInterceptors = connectionInterceptors as? [ConnectionInterceptorAsync] else {
            AppSyncLogger.error("Failed to cast messageInterceptors.")
            return request
        }

        var finalRequest = request
        for interceptor in connectionInterceptors {
            finalRequest = await interceptor.interceptConnection(finalRequest, for: endpoint)
        }

        return finalRequest
    }
}

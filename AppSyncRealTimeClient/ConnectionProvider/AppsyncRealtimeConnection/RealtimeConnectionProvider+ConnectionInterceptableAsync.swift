//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

@available(iOS 13.0.0, *)
extension RealtimeConnectionProvider: ConnectionInterceptableAsync {
    
    public func addInterceptor(_ interceptor: ConnectionInterceptorAsync) {
        useAsyncInterceptors = true
        connectionInterceptors.append(interceptor)
    }
    
    func interceptConnection(_ request: AppSyncConnectionRequest, for endpoint: URL) async -> AppSyncConnectionRequest {
        let connectionInterceptors = connectionInterceptors as! [ConnectionInterceptorAsync]

        var finalRequest = request
        for interceptor in connectionInterceptors {
            finalRequest = await interceptor.interceptConnection(finalRequest, for: endpoint)
        }
        
        return finalRequest
    }
}

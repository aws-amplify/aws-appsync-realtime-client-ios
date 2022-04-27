//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

@available(iOS 13.0.0, *)
extension RealtimeConnectionProvider: MessageInterceptableAsync {
    public func addInterceptor(_ interceptor: MessageInterceptorAsync) {
        messageInterceptors.append(interceptor)
    }
    

    func interceptMessage(_ message: AppSyncMessage, for endpoint: URL) async -> AppSyncMessage {
        let messageInterceptors = messageInterceptors as! [MessageInterceptorAsync]

        var finalMessage = message
        for interceptor in messageInterceptors {
            finalMessage = await interceptor.interceptMessage(finalMessage, for: endpoint)
        }
        
        return finalMessage
    }
    
//    public func addInterceptor(_ interceptor: MessageInterceptor) {
//        messageInterceptors.append(interceptor)
//    }
//
//    public func interceptMessage(_ message: AppSyncMessage, for endpoint: URL) -> AppSyncMessage {
//        let finalMessage = messageInterceptors.reduce(message) { $1.interceptMessage($0, for: endpoint) }
//        return finalMessage
//    }
}

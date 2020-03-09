//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Create connection providers to connect to the websocket endpoint of the AppSync endpoint.
public struct ConnectionProviderFactory {

    public static func createConnectionProvider(for url: URL,
                                                authInterceptor: AuthInterceptor,
                                                connectionType: SubscriptionConnectionType,
                                                unusedConnectionTimeout: DispatchTimeInterval? = nil) -> ConnectionProvider {
        let provider = ConnectionProviderFactory.createConnectionProvider(for: url,
                                                                          connectionType: connectionType,
                                                                          unusedConnectionTimeout: unusedConnectionTimeout)

        if let messageInterceptable = provider as? MessageInterceptable {
            messageInterceptable.addInterceptor(authInterceptor)
        }
        if let connectionInterceptable = provider as? ConnectionInterceptable {
            connectionInterceptable.addInterceptor(RealtimeGatewayURLInterceptor())
            connectionInterceptable.addInterceptor(authInterceptor)
        }

        return provider
    }

    static func createConnectionProvider(for url: URL,
                                         connectionType: SubscriptionConnectionType,
                                         unusedConnectionTimeout: DispatchTimeInterval? = nil) -> ConnectionProvider {
        switch connectionType {
        case .appSyncRealtime:
            let websocketProvider = StarscreamAdapter()
            let connectionProvider = RealtimeConnectionProvider(for: url,
                                                                websocket: websocketProvider,
                                                                unusedConnectionTimeout: unusedConnectionTimeout)
            return connectionProvider
        }
    }
}

//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import os.log

import Foundation
import AppSyncRealTimeClient

class AppSyncRTCProvider: ObservableObject {
    private static var instance: AppSyncRTCProvider?

    public static var `default`: AppSyncRTCProvider {
        guard let existingInstance = instance else {
            // If we can't initialize the provider, we can't do anything meaningful in the
            // app. A crash is appropriate here.
            // swiftlint:disable:next force_try
            let newInstance = try! AppSyncRTCProvider()
            instance = newInstance
            return newInstance
        }
        return existingInstance
    }

    @Published var connectionState: ConnectionState
    @Published var events: [SubscriptionItemEvent]

    @Published var lastData: String?
    @Published var lastError: Error?

    private let url: URL
    private let apiKey: String
    private let connectionProvider: ConnectionProvider

    private let requestString = """
        subscription onCreate {
          onCreateTodo{
            id
            description
            name
          }
        }
        """

    private var subscriptionItem: SubscriptionItem?
    private var subscriptionConnection: SubscriptionConnection?

    init() throws {
        os_log(#function, log: .subscription, type: .debug)
        let json = try AppSyncRTCProvider.retrieveConfigurationJSON()
        guard let data = json as? [String: Any],
            let apiCategoryConfig = data["api"] as? [String: Any],
            let plugins = apiCategoryConfig["plugins"] as? [String: Any],
            let awsAPIPlugin = plugins["awsAPIPlugin"] as? [String: Any],
            let pluginConfig = awsAPIPlugin.first?.value as? [String: Any],
            let endpoint = pluginConfig["endpoint"] as? String,
            let apiKey = pluginConfig["apiKey"] as? String,
            let url = URL(string: endpoint)
            else {
                os_log(#function, log: .subscription, type: .fault)
                throw "Could not retrieve endpoint configuration from amplifyconfiguration.json"
        }

        self.url = url
        self.apiKey = apiKey

        let authInterceptor = AppSyncRTCProvider.makeAuthInterceptor(for: apiKey)
        self.connectionProvider = AppSyncRTCProvider.makeConnectionProvider(
            for: url,
            authInterceptor: authInterceptor
        )

        self.connectionState = .notConnected
        self.events = []
        self.lastData = nil
        self.lastError = nil
    }

    static func retrieveConfigurationJSON() throws -> Any {
        guard let path = Bundle.main.path(forResource: "amplifyconfiguration", ofType: "json") else {
            throw "Could not retrieve configuration file `amplifyconfiguration.json`"
        }

        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data)
        return json
    }

    func handleEvent(event: SubscriptionItemEvent) {
        events.append(event)

        switch event {
        case .connection(let connectionEvent):
            switch connectionEvent {
            case .connected:
                connectionState = .connected
            case .connecting:
                connectionState = .inProgress
            case .disconnected:
                connectionState = .notConnected
            }

        case .failed(let error):
            OSLog.subscription.log(
                "event is error:\(error)",
                log: .subscription,
                type: .error
            )
            AppSyncSubscriptionConnection.logExtendedErrorInfo(for: error)

            lastError = error

        case .data(let data):
            OSLog.subscription.log(
                "event is data:\(data)",
                log: .subscription,
                type: .debug
            )
            lastData = String(data: data, encoding: .utf8)
        }
    }

    func subscribe() {
        os_log(#function, log: .subscription, type: .debug)
        if subscriptionConnection != nil, subscriptionItem != nil {
            unsubscribe()
        }

        let subscriptionConnection = AppSyncRTCProvider
            .makeSubscriptionConnection(using: connectionProvider)

        self.subscriptionConnection = subscriptionConnection
        DispatchQueue.global().async {
            self.subscriptionItem = subscriptionConnection.subscribe(
                requestString: self.requestString,
                variables: nil
            ) { event, item in
                OSLog.subscription.log(
                    "received event:\(event), item:\(item)",
                    log: .subscription,
                    type: .debug
                )

                DispatchQueue.main.async {
                    self.handleEvent(event: event)
                }
            }
        }
    }

    func unsubscribe() {
        os_log(#function)
        guard
            let subscriptionConnection = subscriptionConnection,
            let subscriptionItem = subscriptionItem
            else {
                return
        }
        OSLog.subscription.log(
            "unsubscribe: connection=\(subscriptionConnection); subscriptionItem=\(subscriptionItem)",
            log: .subscription,
            type: .debug
        )
        subscriptionConnection.unsubscribe(item: subscriptionItem)
        self.subscriptionConnection = nil
        self.subscriptionItem = nil
    }

    func disconnect() {
        connectionProvider.disconnect()
    }

    private static func makeSubscriptionConnection(
        using connectionProvider: ConnectionProvider
    ) -> SubscriptionConnection {
        os_log(#function)
        return AppSyncSubscriptionConnection(provider: connectionProvider)
    }

    private static func makeConnectionProvider(
        for url: URL,
        authInterceptor: AuthInterceptor
    ) -> ConnectionProvider {
        os_log(#function)
        return ConnectionProviderFactory.createConnectionProvider(
            for: url,
            authInterceptor: authInterceptor,
            connectionType: .appSyncRealtime
        )
    }

    private static func makeAuthInterceptor(for apiKey: String) -> AuthInterceptor {
        os_log(#function)
        return APIKeyAuthInterceptor(apiKey)
    }

}

extension String: Error { }

extension ConnectionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .connected: return "connected"
        case .inProgress: return "inProgress"
        case .notConnected: return "notConnected"
        }
    }
}

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like viewDidLoad.
    static let subscription = OSLog(subsystem: subsystem, category: "subscription")

    func log(_ message: String, log: OSLog = .default, type: OSLogType = .default) {
        os_log("%@", log: log, type: type, message)
    }
}

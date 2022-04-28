//
//  RealtimeConnectionProvider.swift
//  AppSyncRealTimeClient
//
//  Created by Ameter, Chris on 4/28/22.
//  Copyright © 2022 amazonaws. All rights reserved.
//

import Foundation

public class RealtimeConnectionProvider: RealtimeConnectionProviderBase, ConnectionProvider {
    public func connect() {
        connectionQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard self.status == .notConnected else {
                self.updateCallback(event: .connection(self.status))
                return
            }
            self.status = .inProgress
            self.updateCallback(event: .connection(self.status))
            let request = AppSyncConnectionRequest(url: self.url)

            if self.useAsyncInterceptors {
                if #available(iOS 13.0, *) {
                    Task {
                        let signedRequest = await self.interceptConnection(request, for: self.url)
                        self.websocket.connect(
                            url: signedRequest.url,
                            protocols: ["graphql-ws"],
                            delegate: self
                        )
                    }
                } else {
                    AppSyncLogger.error("Error, attempted to use async-await with a version of iOS < 13.0")
                }
            } else {
                let signedRequest = self.interceptConnection(request, for: self.url)
                DispatchQueue.global().async {
                    self.websocket.connect(
                        url: signedRequest.url,
                        protocols: ["graphql-ws"],
                        delegate: self
                    )
                }
            }
        }
    }

    public func write(_ message: AppSyncMessage) {
        connectionQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            if self.useAsyncInterceptors {
                if #available(iOS 13.0, *) {
                    Task {
                        let signedMessage = await self.interceptMessage(message, for: self.url)
                        self.finishWrite(signedMessage)
                    }
                } else {
                    AppSyncLogger.error("Error, attempted to use async-await with a version of iOS < 13.0")
                }
            } else {
                let signedMessage = self.interceptMessage(message, for: self.url)
                self.finishWrite(signedMessage)
            }
        }
    }
    
    func sendConnectionInitMessage() {
        let message = AppSyncMessage(type: .connectionInit("connection_init"))
        write(message)
    }
}

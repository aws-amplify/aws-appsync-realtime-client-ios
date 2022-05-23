//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

//
//  File.swift
//
//
//  Created by Ameter, Chris on 5/23/22.
//
#if swift(>=5.5.2)

import Foundation

@available(iOS 13.0, *)
actor TaskQueue<Success> {
    private var previousTask: Task<Success, Error>?

    func sync(block: @Sendable @escaping () async throws -> Success) {
        previousTask = Task { [previousTask] in
            _ = await previousTask?.result
            return try await block()
        }
    }

    nonisolated func async(block: @Sendable @escaping () async throws -> Success) {
        Task {
            await sync(block: block)
        }
    }
}

#endif

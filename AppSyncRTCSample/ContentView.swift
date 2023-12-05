//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var provider: AppSyncRTCProvider = .default

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("Subscription state: ")
                Text(provider.connectionState.description)
                Spacer()
            }
            .padding(.bottom, 8)

            HStack(alignment: .top) {
                Text("Events received: ")
                Text("\(provider.events.count)")
                Spacer()
            }
            .padding(.bottom, 8)

            HStack(alignment: .top) {
                Text("Last data: ")
                Text("\(provider.lastData?.description ?? "N/A")")
                Spacer()
            }
            .padding(.bottom, 8)

            HStack(alignment: .top) {
                Text("Last error: ")
                Text("\(provider.lastError?.localizedDescription ?? "N/A")")
                Spacer()
            }
            .padding(.bottom, 24)

            Button("Subscribe") { self.provider.subscribe() }
            Button("Unsubscribe") { self.provider.unsubscribe() }
            Button("Disconnect") { self.provider.disconnect() }

            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

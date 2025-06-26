//
//  ContentView.swift
//  ac
//
//  Created by Giovanni Maya on 6/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var bleVM = BLEViewModel()

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                DeviceListView(bleVM: bleVM)
            } else if authVM.showPinFallback {
                PinFallbackView(authVM: authVM)
            } else {
                LockScreenView(authVM: authVM)
            }
        }.onChange(of: authVM.isAuthenticated) {
            if authVM.isAuthenticated {
                bleVM.startScan()
            }
        }
    }
}

#Preview {
    ContentView()
}

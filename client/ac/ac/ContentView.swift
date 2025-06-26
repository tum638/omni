//
//  ContentView.swift
//  ac
//
//  Created by Giovanni Maya on 6/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                Text("You're authenticated!")
            } else if authVM.showPinFallback {
                PinFallbackView(authVM: authVM)
            } else {
                LockScreenView(authVM: authVM)
            }
        }
    }
}

#Preview {
    ContentView()
}

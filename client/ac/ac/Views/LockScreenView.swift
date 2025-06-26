//
//  LockScreenView.swift
//  ac
//
//  Created by Giovanni Maya on 6/26/25.
//

import SwiftUI

struct LockScreenView: View {
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        VStack {
            Image(systemName: "faceid")
                .resizable()
                .frame(width: 80, height: 80)
                .padding()

            Text("Face ID Required")
                .font(.title)
                .padding()

            Button("Try Again") {
                authVM.authenticate()
            }
            .padding()
        }
        .onAppear {
            authVM.authenticate()
        }
        .alert(isPresented: $authVM.showAuthFailedAlert) {
            Alert(title: Text("Authentication Failed"),
                  message: Text("Please try again."),
                  dismissButton: .default(Text("OK")))
        }
    }
}

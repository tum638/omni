//
//  PinFallbackView.swift
//  ac
//
//  Created by Giovanni Maya on 6/26/25.
//


import SwiftUI

struct PinFallbackView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var pin: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your PIN")
                .font(.title2)

            SecureField("PIN", text: $pin)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)

            Button("Unlock") {
                authVM.verifyPin(pin)
            }
            .padding()
        }
        .padding()
        .alert(isPresented: $authVM.showInvalidPinAlert) {
            Alert(title: Text("Invalid PIN"),
                  message: Text("Please try again."),
                  dismissButton: .default(Text("OK")))
        }
    }
}

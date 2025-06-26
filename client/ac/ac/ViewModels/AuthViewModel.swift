//
//  AuthViewModel.swift
//  ac
//
//  Created by Giovanni Maya on 6/26/25.
//

import LocalAuthentication
import Foundation

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showAuthFailedAlert = false
    @Published var showPinFallback = false
    @Published var showInvalidPinAlert = false
    
    private let correctPin = "1234"

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your app"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                    } else {
                        self.showAuthFailedAlert = true
                        self.showPinFallback = true
                    }
                }
            }
        } else {
            // Biometrics unavailable, show alert or fallback
            DispatchQueue.main.async {
                self.showAuthFailedAlert = true
            }
        }
    }
    
    func verifyPin(_ enteredPin: String) {
            if enteredPin == correctPin {
                isAuthenticated = true
            } else {
                showInvalidPinAlert = true
            }
        }
}

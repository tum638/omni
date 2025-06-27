//
//  SocketViewModel.swift
//  ac
//
//  Created by Tanatswa Manyakara on 6/26/25.
//
import Foundation

import Foundation

class SocketViewModel: ObservableObject {
    private let socketManager: WebsocketManager

    @Published var doorStatus: String = "Locked"

    init(clientId: String) {
        self.socketManager = WebsocketManager(clientId: clientId)

        // Set up callback to handle messages from server
        socketManager.onMessage = { [weak self] message in
            DispatchQueue.main.async {
                switch message {
                case "access_granted":
                    self?.doorStatus = "Unlocked"
                case "access_denied":
                    self?.doorStatus = "Denied"
                default:
                    self?.doorStatus = "Unknown"
                }
            }
        }
    }

    func connect() {
        socketManager.connect()
    }

    func disconnect() {
        socketManager.disconnect()
    }
}


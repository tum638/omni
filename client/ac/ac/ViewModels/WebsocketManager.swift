//
//  WebsocketManager.swift
//  ac
//
//  Created by Tanatswa Manyakara on 6/26/25.
//

import Foundation

class WebsocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var url: URL
    
    var onMessage: ((String) -> Void)?
    
    init(clientId: String) {
        let urlString = "ws://172.20.10.6:8000/ws/client/\(clientId)"
        self.url = URL(string: urlString)!
    }
    
    func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receive()
    }
    
    private func receive() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("❌ WebSocket error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📨 Received text: \(text)")
                    self?.onMessage?(text)
                case .data(let data):
                    print("📨 Received binary data: \(data)")
                @unknown default:
                    break
                }
            }

            // Keep listening
            self?.receive()
        }
    }
    
    func disconnect() {
           webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
}


//
//  DeviceListView.swift
//  ac
//
//  Created by Giovanni Maya on 6/26/25.
//

import SwiftUI

struct DeviceListView: View {
    @ObservedObject var bleVM: BLEViewModel
    @StateObject private var viewModel = SocketViewModel(clientId: "abc124")

    var body: some View {
        VStack {
            Text("Nearby Doors").font(.title)
            
            if bleVM.isScanning {
                
                ProgressView("Scanning for devices...")
                    .padding()
                    .task {
                        viewModel.connect()
                    }
            }

            if bleVM.discoveredDevices.isEmpty && !bleVM.isScanning {
                Text("No devices found.")
                    .foregroundColor(.secondary)
            }

            List(bleVM.discoveredDevices.filter { $0.name != "Unknown" }) { device in
                HStack {
                    VStack(alignment: .leading) {
                        Text(device.name)
                        Text(device.peripheral.identifier.uuidString).font(.caption)
                    }
                    Spacer()
                    Button("Request Access") {
                        
                        bleVM.connectToDevice(device)
                    }
                    Button("Open Door") {
                        bleVM.sendData(clientID: "abc124", deviceID: "door1")
                    }
                    .disabled(bleVM.unlockCharacteristic == nil)
                }
            }
        }
        .onAppear {
            bleVM.startScan()
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
}

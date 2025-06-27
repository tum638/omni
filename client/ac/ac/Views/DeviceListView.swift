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
        ScrollView{
            Text("Doors").font(.title3).fontWeight(.medium)
                .padding(.top, 20)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            
            HStack {
                Text("Nearby")
                    .font(.headline).foregroundColor(.gray).opacity(0.75)
                Spacer()
                Button("Edit") {
                    
                }
                .font(.headline).foregroundColor(.gray).opacity(0.75)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            VStack {
                VStack(spacing: 12) {
                        ForEach(bleVM.discoveredDevices.filter { device in
                            let lowercasedName = device.name.lowercased()
                            return lowercasedName.contains("door") || lowercasedName.contains("arduino")
                        }) { device in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(device.name)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .fontWeight(.medium)

                                    Text("\(Int.random(in: 2...10))ft away")
                                        .font(.headline)
                                        .foregroundColor(.gray.opacity(0.75))
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Border
                                        .background(Color.white.cornerRadius(12))     // Fill with white
                                )
                                
                                    
                                
                                HStack(spacing: 4) {
                                    Button(action: {
                                        bleVM.connectToDevice(device)
                                    }) {
                                        Image(systemName: device.connectionAttempted
                                              ? (device.isUnlocked ? "checkmark" : "xmark")
                                              : "lock.open.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .padding(18)
                                        .foregroundColor(.white)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    device.connectionAttempted
                                                    ? (device.isUnlocked ? Color.green : Color.red)
                                                    : Color.green
                                                )
                                        )}
                                    .buttonStyle(.plain)

                                    Button(action: {
                                        bleVM.sendData(clientID: "abc124", deviceID: "door1")
                                    }) {
                                        Image(systemName: "hand.wave.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                            .padding(12)
                                            .foregroundColor(.black).opacity(0.85)
                                    }
                                    .frame(width: 64, height: 64)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .buttonStyle(.plain)
                                    .disabled(bleVM.unlockCharacteristic == nil)
                                }
                            }
                            .frame(maxWidth: .infinity)
//                            .padding()
                            .background(Color.white)
                        }
                    }.frame(maxWidth: .infinity)
            }
            .padding()
            .onAppear {
                bleVM.startScan()
            }
        }
    }
}


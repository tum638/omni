//
//  BLEViewModel.swift
//  ac
//
//  Created by Giovanni Maya on 6/26/25.
//

import Foundation
import CoreBluetooth

class BLEViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var isUnlocked = false
    @Published var isScanning = false

    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    var unlockCharacteristic: CBCharacteristic?

    let SERVICE_UUID = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")
    let CHARACTERISTIC_UUID = CBUUID(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Bluetooth Lifecycle

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on. Starting scan...")
            startScan()
        } else {
            print("Bluetooth not available: \(central.state.rawValue)")
            isScanning = false
        }
    }

    // MARK: - Scanning

    func startScan() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth not powered on yet. Will scan later.")
            return
        }

        discoveredDevices.removeAll()
        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: nil)

        // Automatically stop scanning after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.stopScan()
        }
    }

    func stopScan() {
        centralManager.stopScan()
        isScanning = false
        print("Stopped scanning.")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? "Unknown"

        if !discoveredDevices.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            let device = DiscoveredDevice(peripheral: peripheral, name: name)
            DispatchQueue.main.async {
                self.discoveredDevices.append(device)
                print("Discovered: \(device.name)")
            }
        }
    }

    // MARK: - Connection

    func connectToDevice(_ device: DiscoveredDevice) {
        targetPeripheral = device.peripheral
        targetPeripheral?.delegate = self
        centralManager.connect(device.peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to device: \(peripheral.name ?? "Unnamed")")
        peripheral.discoverServices([SERVICE_UUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Service discovery error: \(error.localizedDescription)")
            return
        }

        peripheral.services?.forEach {
            peripheral.discoverCharacteristics([CHARACTERISTIC_UUID], for: $0)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Characteristic discovery error: \(error.localizedDescription)")
            return
        }

        service.characteristics?.forEach {
            if $0.uuid == CHARACTERISTIC_UUID {
                print("Unlock characteristic found.")
                self.unlockCharacteristic = $0
            }
        }
    }

    // MARK: - Unlock Command

    func sendUnlockCommand() {
        guard let characteristic = unlockCharacteristic else {
            print("Unlock characteristic not available.")
            return
        }

        let data = "UNLOCK".data(using: .utf8)!
        targetPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        isUnlocked = true
        print("Sent unlock command.")
    }
    
    func sendData(_ message: String) {
        guard let characteristic = unlockCharacteristic else {
            print("❌ No writable characteristic available.")
            return
        }

        guard let data = message.data(using: .utf8) else {
            print("❌ Couldn't convert message to data.")
            return
        }

        targetPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        print("✅ Sent message: \(message)")
    }
}

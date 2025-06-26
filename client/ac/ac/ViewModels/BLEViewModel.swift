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

    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    var unlockCharacteristic: CBCharacteristic?

    let SERVICE_UUID = CBUUID(string: "12345678-1234-1234-1234-123456789abc")
    let CHARACTERISTIC_UUID = CBUUID(string: "abcd1234-5678-90ab-cdef-1234567890ab")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not enabled")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? "Unknown"
        if !discoveredDevices.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            let device = DiscoveredDevice(peripheral: peripheral, name: name)
            DispatchQueue.main.async {
                self.discoveredDevices.append(device)
            }
        }
    }

    func connectToDevice(_ device: DiscoveredDevice) {
        targetPeripheral = device.peripheral
        targetPeripheral?.delegate = self
        centralManager.connect(device.peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([SERVICE_UUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach {
            peripheral.discoverCharacteristics([CHARACTERISTIC_UUID], for: $0)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach {
            if $0.uuid == CHARACTERISTIC_UUID {
                self.unlockCharacteristic = $0
            }
        }
    }

    func sendUnlockCommand() {
        guard let characteristic = unlockCharacteristic else { return }
        let data = "UNLOCK".data(using: .utf8)!
        targetPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        isUnlocked = true
    }
}

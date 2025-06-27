//
//  DiscoveredDevice.swift
//  ac
//
//  Created by Giovanni Maya on 6/26/25.
//

import CoreBluetooth

struct DiscoveredDevice: Identifiable {
    let id = UUID()
    let peripheral: CBPeripheral
    let name: String
    
    var connectionAttempted: Bool = false
    var isUnlocked: Bool = false
}

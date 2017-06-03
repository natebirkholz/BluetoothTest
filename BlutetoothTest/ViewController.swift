//
//  ViewController.swift
//  BlutetoothTest
//
//  Created by Nathan Birkholz on 5/31/17.
//  Copyright © 2017 natebirkholz. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var label: UILabel!
    var centralManager: CBCentralManager!
    var peripheralController: CBPeripheral!
    let timeUUID = CBUUID(string: "D701F42C-49E1-48E9-B6E2-3862FEB2F550")
    var central : CBCentral!

    override func viewDidLoad() {
        super.viewDidLoad()

        let labelFor = UILabel(frame: CGRect(x: 100.0, y: 100.0, width: 250.0, height: 24.0))
        labelFor.font = UIFont.systemFont(ofSize: 14.0)
        label = labelFor
        view.addSubview(labelFor)

        let manager = CBCentralManager(delegate: self, queue: nil, options: nil)
        centralManager = manager
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state.rawValue)
        centralManager.scanForPeripherals(withServices: [timeUUID], options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralController = peripheral
        centralManager.connect(peripheral, options: nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid.uuidString == timeUUID.uuidString {
            if let valueFrom = characteristic.value  {
                if let timeStamp = String(data: valueFrom, encoding: .utf8) {
                    if UIApplication.shared.applicationState == .active {
                        label.text = timeStamp
                        print("ACTIVE \(timeStamp)")
                    } else if UIApplication.shared.applicationState == .background {
                        print("BACKGROUND \(timeStamp)")
                    } else if UIApplication.shared.applicationState == .inactive {
                        print("INACTIVE \(timeStamp)")
                    }
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if service.uuid.uuidString == timeUUID.uuidString {
            peripheralController.setNotifyValue(true, for: service.characteristics!.first!)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if invalidatedServices.count > 0 {
            print("invalidated: ", invalidatedServices)
        }
    }
}


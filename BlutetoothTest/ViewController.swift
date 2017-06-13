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

    var timestampLabel: UILabel?
    var timestampLegendLabel: UILabel?
    var subscriptionLabel: UILabel?
    var centralManager: CBCentralManager?
    var remotePeripheral: CBPeripheral?
    let streamServiceUuid = CBUUID(string: "D701F42C-49E1-48E9-B6E2-3862FEB2F550")
    var central : CBCentral?

    override func viewDidLoad() {
        super.viewDidLoad()

        let timestampLabel = UILabel(frame: CGRect(x: (view.bounds.width / 2) - 125, y: 100.0, width: 250.0, height: 20))
        timestampLabel.font = UIFont.systemFont(ofSize: 17.0)
        timestampLabel.textAlignment = .center
        timestampLabel.text = "------"
        view.addSubview(timestampLabel)
        self.timestampLabel = timestampLabel

        let timestampLegendLabel = UILabel(frame: CGRect(x: (view.bounds.width / 2) - 125, y: 75, width: 250.0, height: 25))
        timestampLegendLabel.font = UIFont.systemFont(ofSize: 20)
        timestampLegendLabel.textAlignment = .center
        timestampLegendLabel.text = "Timestamp:"
        view.addSubview(timestampLegendLabel)
        self.timestampLegendLabel = timestampLegendLabel

        let subscriptionLabel = UILabel(frame: CGRect(x: (view.bounds.width / 2) - 75, y: 150, width: 150, height: 25))
        subscriptionLabel.backgroundColor = UIColor.red.withAlphaComponent(0.33)
        subscriptionLabel.textAlignment = .center
        subscriptionLabel.text = "Unsubscribed..."
        view.addSubview(subscriptionLabel)
        self.subscriptionLabel = subscriptionLabel

        let centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        self.centralManager = centralManager
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state.rawValue)
        centralManager?.scanForPeripherals(withServices: [streamServiceUuid], options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        remotePeripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == streamServiceUuid {
            if let value = characteristic.value, let timeStamp = String(data: value, encoding: .utf8) {
                if UIApplication.shared.applicationState == .active {
                    timestampLabel?.text = timeStamp
                    print("ACTIVE \(timeStamp)")
                } else if UIApplication.shared.applicationState == .background {
                    print("BACKGROUND \(timeStamp)")
                } else if UIApplication.shared.applicationState == .inactive {
                    print("INACTIVE \(timeStamp)")
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if service.uuid == streamServiceUuid {
            if let characteristic = service.characteristics?.first {
                remotePeripheral?.setNotifyValue(true, for: characteristic)
                subscriptionLabel?.text = "Subscribed!"
                subscriptionLabel?.backgroundColor = UIColor.green.withAlphaComponent(0.33)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if invalidatedServices.count > 0 {
            print("invalidated: ", invalidatedServices)
        }
    }
}


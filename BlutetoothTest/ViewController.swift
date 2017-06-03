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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state.rawValue)
        centralManager.scanForPeripherals(withServices: [timeUUID], options: nil)
        print("scanning")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)

        print("connected")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name as Any)
        print(advertisementData[CBAdvertisementDataServiceUUIDsKey] as! Array<CBUUID>)
        self.peripheralController = peripheral

        self.centralManager.connect(peripheral, options: nil)
    }



    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if characteristic.uuid.uuidString == timeUUID.uuidString {
            if let valueFrom = characteristic.value  {
                if let this = String(data: valueFrom, encoding: .utf8) {
                    if UIApplication.shared.applicationState == .active {
                        label.text = this
                        print("ACTIVE \(this)")
                    } else if UIApplication.shared.applicationState == .background {
                        print("BACKGROUND \(this)")
                    } else if UIApplication.shared.applicationState == .inactive {
                        print("INACTIVE \(this)")
                    }
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let descriptors = characteristic.descriptors {
            print("descriptors: ", descriptors)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        if service.uuid.uuidString == timeUUID.uuidString {
            peripheralController.setNotifyValue(true, for: service.characteristics!.first!)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("services: ", peripheral.services as Any)
        for service in peripheral.services! {
            print(service.uuid)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if invalidatedServices.count > 0 {
            print("invalidated: ", invalidatedServices)
        }
    }
}

//                    if UIApplication.shared.applicationState == .background {
//                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
//                        let content = UNMutableNotificationContent()
//                        content.title = "Now"
//                        content.body = "\(this)"
//                        content.sound = UNNotificationSound.default()
//                        let notification = UNNotificationRequest(identifier: "ttt", content: content, trigger: nil)
//
//                        UNUserNotificationCenter.current().add(notification) {
//                            error in
//                            if let error = error {
//                                print("Problem adding notification: \(error.localizedDescription)")
//                            }
//                            else {
//                            }
//                        }
//                    }


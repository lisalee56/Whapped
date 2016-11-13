//
//  ViewController.swift
//  BluetoothTestApp
//
//  Created by Kristin Ho on 11/12/16.
//  Copyright © 2016 Kristin Ho. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBCentralManagerDelegate,CBPeripheralManagerDelegate, CBPeripheralDelegate{
    
    
    var manager:CBCentralManager!
    var peripheralManager:CBPeripheralManager!
    
    var peripheral:CBPeripheral!
    let WHAPPED_PLAYER = "Stick-Man"
    
    let WHAPPED_SERVICE_UUID =
        CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de") // will determine later
    let WHAPPED_PLAYER_UUID =
        CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        // Do any additional setup after loading the view, typically from a nib.
        manager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        print("did receie memory warning")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // === CENTRAL MANAGER DELEGATE METHODS ===
    
    // scan for peripherals
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // TO DO: remove all peripherals in a stored peripheral list, so they can be re-added
            
            print("Will be scanning for peripherals");
            central.scanForPeripherals(withServices: [WHAPPED_SERVICE_UUID], options: nil)
            
            // TO DO: put the above on the main thread and say "wait for it to be done" before the next action (because we need the array to be filled before taking action)
            // OR: gcd's dispatch_after
        }
        else {
            print("Bluetooth not available.")
            // Send alert to user to enable bluetooth
        }
    }
    
    
    func centralManager(_: CBCentralManager, didDiscover: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        
        // TO DO: add peripherals to a list
        
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        
        if device?.contains(WHAPPED_PLAYER) == true {
            // TO DO: don't have this code but add to list
            print("Discovered peripheral")
            print(device)
            print("Will stop scanning")
            self.manager.stopScan()
            self.peripheral = didDiscover
            self.peripheral.delegate = self
            manager.connect(peripheral, options: nil)
        }else{
            print("Discovered peripheral without whapped player name")
            print(device)
        }
    }
    
    // list of services
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral) {
        
        // TO DO: see if I can send something to that peripheral
        print("Connected with peripheral")
        peripheral.discoverServices(nil)
    }
    
    // list of characteristics
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            print("Peripheral's service is %@", thisService)
            
            if service.uuid == WHAPPED_SERVICE_UUID {
                peripheral.discoverCharacteristics(
                    nil,
                    for: thisService
                )
            }
        }
    }
    
    // characteristics changed -- notify
    func peripheral(
        peripheral: CBPeripheral,
        didDiscoverCharacteristicsForService service: CBService,
        error: NSError?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            print("Peripheral's characteristic is %@", thisCharacteristic)
            
            if thisCharacteristic.uuid == WHAPPED_PLAYER_UUID {
                self.peripheral.setNotifyValue(
                    true,
                    for: thisCharacteristic
                )
            }
        }
    }
    
    // changed characteristics are here
    func peripheral(
        peripheral: CBPeripheral,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
        
        if characteristic.uuid == WHAPPED_PLAYER_UUID {
            print(characteristic.value as Any)
        }
    }
    
    // if disconnected to a peripheral
    func centralManager(
        central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: NSError?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
    
    // === PERIPHERAL MANAGER DELEGATE METHODS ===
    
    // note: has function called "respond to" that responds to r/w requests from a central!
    
    @available(iOS 6.0, *)
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state == CBManagerState.poweredOn {
            
            print("Will call start advertising")
            peripheralManager.add(CBMutableService(type: WHAPPED_SERVICE_UUID, primary: true))
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: WHAPPED_SERVICE_UUID, CBAdvertisementDataLocalNameKey: WHAPPED_PLAYER])
        }else{
            print("Bluetooth advertising not available")
        }
        
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager,error: Error?){
        print("Peripheral manager started advertising self method")
        if(error != nil){
            print("Peripheral manager error'd when trying to advertise due to: %@", error!)
        }
    }
    
    
    
}


import CoreBluetooth
import os


public class BlueCentralManager: NSObject, ObservableObject {

  public private(set) lazy var central: CBCentralManager = {
    CBCentralManager(delegate: self, queue: nil)
  }()
  public private(set) var selectedPeripheral: CBPeripheral?

  func discoverPeripherals() {
    let connected = central.retrieveConnectedPeripherals(withServices: [])
    if let first = connected.first {
      print(first)
    } else {
      central.scanForPeripherals(withServices: [PeripheralService.serviceUUID],
                                 options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
  }
}


extension BlueCentralManager: CBCentralManagerDelegate {

  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    os_log("Bluetooth status: %@", central.state.string)
    switch central.state {
    case .unknown:      ()
    case .resetting:    ()
    case .unsupported:  ()
    case .unauthorized: ()
    case .poweredOff:   ()
    case .poweredOn:    discoverPeripherals()
    @unknown default:   ()
    }
  }

  public func centralManager(_ central: CBCentralManager,
                             didDiscover peripheral: CBPeripheral,
                             advertisementData: [String : Any],
                             rssi RSSI: NSNumber) {
    if selectedPeripheral != peripheral {
      os_log("Central will connect to: %@ at %d", peripheral, RSSI.intValue)
      selectedPeripheral = peripheral
      central.connect(selectedPeripheral!, options: nil)
    }
  }

  public func centralManager(_ central: CBCentralManager,
                             didConnect peripheral: CBPeripheral) {
    os_log("Central did connect")
    self.central.stopScan()
    peripheral.delegate = self
    peripheral.discoverServices(nil)
  }

  public func centralManager(_ central: CBCentralManager,
                             didFailToConnect peripheral: CBPeripheral,
                             error: Error?) {
    os_log("Central failed to connect")
  }

  public func centralManager(_ central: CBCentralManager,
                             didDisconnectPeripheral peripheral: CBPeripheral,
                             error: Error?) {
    os_log("Central did disconnect")
  }

  public func centralManager(_ central: CBCentralManager,
                             connectionEventDidOccur event: CBConnectionEvent,
                             for peripheral: CBPeripheral) {
    os_log("Central connection event")
  }

  public func centralManager(_ central: CBCentralManager,
                             didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
    os_log("Central did update ANCS authorization")
  }

  //public func centralManager(_ central: CBCentralManager,
  //                           willRestoreState dict: [String : Any]) {}
}


extension BlueCentralManager: CBPeripheralDelegate {

  public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
    os_log("Peripheral did update name to: %@", peripheral.name ?? "no name")
  }
  public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    os_log("Peripheral did modify services")
  }
  public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
    os_log("Peripheral did update RSSI")
  }
  public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    os_log("Peripheral did read RSSI")
  }
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    os_log("Peripheral did discover services: ")
  }
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
    os_log("Peripheral did discover included services")
  }
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    os_log("Peripheral did discover characteristics")
  }
  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    os_log("Peripheral did update value for characteristic")
  }
  public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    os_log("Peripheral did write value for characteristic")
  }
  public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    os_log("Peripheral did update notifications")
  }
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
    os_log("Peripheral did discover descriptor")
  }
  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
    os_log("Peripheral did update value for descriptor")
  }
  public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
    os_log("Peripheral did write value for descriptor")
  }
  public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
    os_log("Peripheral is ready to send w/o response")
  }
  public func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
    os_log("Peripheral did open channel")
  }
}

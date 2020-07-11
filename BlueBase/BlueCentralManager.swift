
import CoreBluetooth
import os


public class BlueCentralManager: NSObject, ObservableObject {

  public private(set) lazy var central: CBCentralManager = {
    CBCentralManager(delegate: self, queue: nil)
  }()
  public private(set) var selectedPeripheral: CBPeripheral?
  var selectedCharacteristic: CBCharacteristic?

  func discoverPeripherals() {
    let connected = central.retrieveConnectedPeripherals(withServices: [])
    if let first = connected.first {
      print(first)
    } else {
      central.scanForPeripherals(withServices: [PeripheralService.serviceUUID],
                                 options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
  }

  func disconnectSelectedPeripheral() {
    guard let selected = selectedPeripheral,
          case .connected = selected.state else { return }
    (selected.services ?? []).forEach { service in
      (service.characteristics ?? []).forEach { characteristic in
        if characteristic.uuid == PeripheralService.characteristicUUID,
           characteristic.isNotifying {
          self.selectedPeripheral?.setNotifyValue(false, for: characteristic)
        }
      }
    }
    central.cancelPeripheralConnection(selected)
    //selectedPeripheral = nil
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

  public func peripheral(_ peripheral: CBPeripheral,
                         didModifyServices invalidatedServices: [CBService]) {
    for service in invalidatedServices
    where service.uuid == PeripheralService.serviceUUID {
      os_log("Peripheral did invalidate services")
      peripheral.discoverServices([PeripheralService.serviceUUID])
    }
  }

  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard error == nil else {
      os_log("Discovered peripheral services ERROR: %@", error!.localizedDescription)
      disconnectSelectedPeripheral()
      return
    }
    guard let services = peripheral.services, services.count > 0 else {
      os_log("Discovered peripheral without services")
      return
    }
    os_log("Peripheral did discover services")
    services.forEach {
      peripheral.discoverCharacteristics([PeripheralService.characteristicUUID], for: $0)
    }
  }

  public func peripheral(_ peripheral: CBPeripheral,
                         didDiscoverCharacteristicsFor service: CBService,
                         error: Error?) {
    guard error == nil else {
      os_log("Discovered peripheral service characteristics ERROR: %@", error!.localizedDescription)
      disconnectSelectedPeripheral()
      return
    }
    guard let characteristics = service.characteristics, characteristics.count > 0 else {
      os_log("Discovered peripheral service without characteristics")
      return
    }
    for characteristic in characteristics {
      if characteristic.uuid != PeripheralService.characteristicUUID {
        os_log("Discovered peripheral service characteristic ignored: %@", characteristic.uuid)
        continue
      }
      os_log("Subscribing to peripheral service characteristic: %@", characteristic.uuid)
      selectedCharacteristic = characteristic
      peripheral.setNotifyValue(true, for: characteristic)
    }
  }

  public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    os_log("Peripheral did update notifications")
  }

  public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
    os_log("Peripheral did update RSSI")
  }
  public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    os_log("Peripheral did read RSSI")
  }
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
    os_log("Peripheral did discover included services")
  }
  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    os_log("Peripheral did update value for characteristic")
  }
  public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    os_log("Peripheral did write value for characteristic")
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

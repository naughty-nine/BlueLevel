
import CoreBluetooth
import os


public class BluePeripheralManager: NSObject, ObservableObject {

  public private(set) lazy var peripheral: CBPeripheralManager = {
    CBPeripheralManager(delegate: self, queue: nil, options: nil)
  }()
  var characteristics: CBMutableCharacteristic?

  func setup() {
    let characteristics
      = CBMutableCharacteristic(type: PeripheralService.characteristicUUID,
                                properties: [.notify, .writeWithoutResponse],
                                value: nil,
                                permissions: [.readable, .writeable])
    let service = CBMutableService(type: PeripheralService.serviceUUID, primary: true)
    service.characteristics = [characteristics]
    peripheral.add(service)
    self.characteristics = characteristics
    peripheral.startAdvertising(
      [CBAdvertisementDataServiceUUIDsKey: [PeripheralService.serviceUUID],
       CBAdvertisementDataLocalNameKey: PeripheralService.serviceName]
    )
  }
}


extension BluePeripheralManager: CBPeripheralManagerDelegate {
  public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    os_log("Bluetooth status: %@", peripheral.state.string)
    switch peripheral.state {
    case .unknown:      ()
    case .resetting:    ()
    case .unsupported:  ()
    case .unauthorized: ()
    case .poweredOff:   ()
    case .poweredOn:    setup()
    @unknown default:   ()
    }
  }

  public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager,
                                                   error: Error?) {
    os_log("Peripheral did start advertising")
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                didAdd service: CBService,
                                error: Error?) {
    os_log("Peripheral did add service")
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                central: CBCentral,
                                didSubscribeTo characteristic: CBCharacteristic) {
    os_log("Peripheral central did subscribe")
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                central: CBCentral,
                                didUnsubscribeFrom characteristic: CBCharacteristic) {
    os_log("Peripheral central did unsubscribe")
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                didReceiveRead request: CBATTRequest) {
    os_log("Peripheral did receive read")
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                didReceiveWrite requests: [CBATTRequest]) {
    os_log("Peripheral did receive write")
  }

  public func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
    os_log("Peripheral is ready to update")
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                didPublishL2CAPChannel PSM: CBL2CAPPSM,
                                error: Error?) {
    os_log("Peripheral did publish L2CAP channel")
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                didUnpublishL2CAPChannel PSM: CBL2CAPPSM,
                                error: Error?) {
    os_log("Peripheral did unpublish L2CAP")
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                didOpen channel: CBL2CAPChannel?,
                                error: Error?) {
    os_log("Peripheral did open L2CAP")
  }

  //public func peripheralManager(_ peripheral: CBPeripheralManager,
  //                                willRestoreState dict: [String : Any]) {
  //  os_log("Peripheral will restore state")
  //}
}

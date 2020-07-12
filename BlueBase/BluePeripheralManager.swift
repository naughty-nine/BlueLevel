
import CoreBluetooth
import os
import SwiftUI


public class BluePeripheralManager: NSObject, ObservableObject {

  // MARK: public / published
  @Published public var isAdvertising: Bool = false {
    didSet {
      if isAdvertising {
        peripheral.startAdvertising(PeripheralService.advertisement)
      } else {
        peripheral.stopAdvertising()
      }
    }
  }
  public var isAdvertisingBinding: Binding<Bool> {
    Binding(get: { self.isAdvertising },
            set: { self.isAdvertising = $0 })
  }
  @Published public var connectedCentralName: String = ""

  // MARK: private / internal
  private var peripheral: CBPeripheralManager
  private var characteristics: CBMutableCharacteristic
  private var connectedCentral: CBCentral? {
    didSet { connectedCentralName = connectedCentral?.identifier.uuidString ?? "" }
  }
  private var dataToSend = Data()
  private var dataToSendIndex = 0
  private var shouldSendEom = false

  public override init() {
    peripheral = CBPeripheralManager(delegate: nil, queue: nil, options: nil)
    characteristics = CBMutableCharacteristic(type: PeripheralService.characteristicUUID,
                                              properties: [.notify, .writeWithoutResponse],
                                              value: nil,
                                              permissions: [.readable, .writeable])
    super.init()
    peripheral.delegate = self
  }

  private func setup() {
    let service = CBMutableService(type: PeripheralService.serviceUUID, primary: true)
    service.characteristics = [characteristics]
    peripheral.add(service)
    isAdvertising = true
  }

  private func sendData() {
    if shouldSendEom {
      let didSend = peripheral.updateValue("EOM".data(using: .utf8)!,
                                           for: characteristics,
                                           onSubscribedCentrals: nil)
      if didSend {
        shouldSendEom = false
        os_log("%@ : Sent EOM", #function)
      }
      // Didn't send. wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
      return
    }
    if dataToSendIndex >= dataToSend.count {
      os_log("%@ : Data was sent", #function)
      return
    }
    var didSend = true
    while didSend {
      var amountToSend = dataToSend.count - dataToSendIndex
      if let mtu = connectedCentral?.maximumUpdateValueLength {
        amountToSend = min(amountToSend, mtu)
      }
      let chunk = dataToSend.subdata(in: dataToSendIndex..<(dataToSendIndex+amountToSend))
      didSend = peripheral.updateValue(chunk,
                                       for: characteristics,
                                       onSubscribedCentrals: nil)
      if !didSend { return }
      let sentString = String(data: chunk, encoding: .utf8)
      os_log("%@ : Sent %@ (%d bytes)",
             #function, String(describing: sentString), amountToSend)
      dataToSendIndex += amountToSend
      if dataToSendIndex >= dataToSend.count {
        shouldSendEom = true
        let eomSent = peripheral.updateValue("EOM".data(using: .utf8)!,
                                             for: characteristics,
                                             onSubscribedCentrals: nil)
        if eomSent {
          shouldSendEom = false
          os_log("%@ : Sent EOM", #function)
        }
        return
      }
    }
  }
}

// MARK: - CBPeripheralManagerDelegate

extension BluePeripheralManager: CBPeripheralManagerDelegate {

  public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    os_log("PeripheralManager updated state: %@", peripheral.state.string)
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

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                didAdd service: CBService,
                                error: Error?) {
    os_log("PeripheralManager added service. Nothing to do")
  }

  public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager,
                                                   error: Error?) {
    os_log("PeripheralManager started advertising. Nothing to do.")
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                central: CBCentral,
                                didSubscribeTo characteristic: CBCharacteristic) {
    os_log("Central subscribed to PeripheralManager characteristic. Send initial data.")
    connectedCentral = central
    isAdvertising = false
    dataToSend = "Pshhhhh. No sound".data(using: .utf8)!
    dataToSend = Constants.Commentarii.text.data(using: .utf8)!
    dataToSendIndex = 0
    sendData()
  }

  public func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
    os_log("PeripheralManager is ready to update. Continue send data.")
    sendData()
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                central: CBCentral,
                                didUnsubscribeFrom characteristic: CBCharacteristic) {
    os_log("Central did unsubscribe from PeripheralManager.")
    connectedCentral = nil
    isAdvertising = true
  }

  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                didReceiveRead request: CBATTRequest) {
    os_log("Peripheral did receive read")
  }
  public func peripheralManager(_ peripheral: CBPeripheralManager,
                                didReceiveWrite requests: [CBATTRequest]) {
    os_log("Peripheral did receive write")
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
  //                              willRestoreState dict: [String : Any]) {
  //  os_log("Peripheral will restore state")
  //}
}


import CoreBluetooth
import CoreMotion
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
  private var dataToSend = Data() {
    didSet { dataToSendIndex = 0 }
  }
  private var dataToSendIndex = 0
  private var shouldSendEom = false {
    didSet {
      if !shouldSendEom {
        dataToSend = Data()
      }
    }
  }
  private var motionManager: CMMotionManager

  public override init() {
    peripheral = CBPeripheralManager(delegate: nil, queue: nil, options: nil)
    characteristics = CBMutableCharacteristic(type: PeripheralService.characteristicUUID,
                                              properties: [.notify, .writeWithoutResponse],
                                              value: nil,
                                              permissions: [.readable, .writeable])
    motionManager = CMMotionManager()
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
      if sendEom() {
        shouldSendEom = false
        os_log("%@ : Sent EOM", #function)
        return
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
        if sendEom() {
          shouldSendEom = false
          os_log("%@ : Sent EOM", #function)
        }
        return
      }
    }
  }

  private func sendEom() -> Bool {
    peripheral.updateValue(PeripheralService.eom.data(using: .utf8)!,
                           for: characteristics,
                           onSubscribedCentrals: nil)
  }

  private func startMotion() {
    guard motionManager.isDeviceMotionAvailable else {
      os_log("%@ : DeviceMotion unavailable.", #function)
      return
    }
    guard !motionManager.isDeviceMotionActive else  {
      os_log("%@ : DeviceMotion already active", #function)
      return
    }
    motionManager.deviceMotionUpdateInterval = 1.0 / 40
    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
      guard error == nil else {
        os_log("DeviceMotion update failed with %@", error!.localizedDescription)
        return
      }
      guard let motion = motion else {
        os_log("DeviceMotion data is nil.")
        return
      }
      guard self?.dataToSend.isEmpty ?? false else {
        os_log("PeripheralManager is busy sending data. Skip this datum.")
        return
      }
      let level = LevelData(deviceMotion: motion)
      guard let levelData = try? JSONEncoder().encode(level) else {
        os_log("DeviceMotion data failed to encode.")
        return
      }
      self?.dataToSend = levelData
      self?.sendData()
    }
  }

  private func stopMotion() {
    motionManager.stopDeviceMotionUpdates()
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
    sendData()
    startMotion()
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
    stopMotion()
    isAdvertising = true
  }

  // MARK: Not yet called
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

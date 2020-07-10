
import CoreBluetooth
import SwiftUI


public class BlueCentralManager: NSObject, ObservableObject {

  public private(set) lazy var central: CBCentralManager = {
    CBCentralManager(delegate: self, queue: nil)
  }()
}


extension BlueCentralManager: CBCentralManagerDelegate {

  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    print(central.state.string)
    switch central.state {
    case .unknown: ()
    case .resetting: ()
    case .unsupported: ()
    case .unauthorized: ()
    case .poweredOff: ()
    case .poweredOn:
      central.scanForPeripherals(withServices: nil, options: nil)
    @unknown default: ()
    }
  }

  public func centralManager(_ central: CBCentralManager,
                      didDiscover peripheral: CBPeripheral,
                      advertisementData: [String : Any],
                      rssi RSSI: NSNumber) {
    //    print(central)
    //    print(peripheral)
    print(advertisementData)
    //    print(RSSI)
  }
}

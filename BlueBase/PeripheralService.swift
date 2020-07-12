
import CoreBluetooth


public struct PeripheralService {
  public static let serviceUUID = CBUUID(string: "42424242-4242-4242-4242-424242424242")
  public static let serviceName = "BluePeripheral"
  public static let characteristicUUID = CBUUID(string: "09090909-0909-0909-0909-090909090909")
  public static let advertisement: [String: Any] = [
    CBAdvertisementDataServiceUUIDsKey: [PeripheralService.serviceUUID],
    CBAdvertisementDataLocalNameKey: PeripheralService.serviceName
  ]
  public static let eom = "EOM"
}


import CoreBluetooth


extension CBManagerState {

  public var string: String {
    switch self {
    case .unknown:      return "unknown"
    case .resetting:    return "resetting"
    case .unsupported:  return "unsupported"
    case .unauthorized: return "unauthorized"
    case .poweredOff:   return "off"
    case .poweredOn:    return "on"
    @unknown default:   return "@unknown"
    }
  }
}

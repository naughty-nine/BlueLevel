
import CoreMotion
import CoreGraphics


public struct LevelData: Codable {
  public let xDegrees: Double
  public let yDegrees: Double

  public init(deviceMotion motion: CMDeviceMotion) {
    self.xDegrees = motion.attitude.pitch * 180 / .pi
    self.yDegrees = motion.attitude.roll * 180 / .pi
  }

  public func xScaled(toContainerWidth width: CGFloat) -> CGFloat {
    scale(value: xDegrees, toBase: width)
  }

  public func yScaled(toContainerHeight height: CGFloat) -> CGFloat {
    scale(value: yDegrees, toBase: height)
  }

  private func scale(value: Double, toBase base: CGFloat) -> CGFloat {
    let bounded: CGFloat
    if value >= 0 {
      bounded = CGFloat(min(15, value))
    } else {
      bounded = CGFloat(max(-15, value))
    }
    return base / 2.0 / 15.0 * bounded
  }
}

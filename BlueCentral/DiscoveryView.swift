
import SwiftUI
import BlueBase


struct DiscoveryView: View {
  @ObservedObject var central: BlueCentralManager
  let indexOffset: CGFloat = 20

  var body: some View {
    VStack {
      Text("Central role is scanning for peripherals")
      HStack {
        Text("Peripheral:")
        Spacer()
        Text(central.selectedPeripheral?.name ?? "none")
      }
      HStack {
        Text("Characteristic:")
        Spacer()
        Text(central.selectedCharacteristic?.uuid.uuidString ?? "none")
          .lineLimit(1)
      }
      GeometryReader { geo in
        ZStack {
          Rectangle()
            .fill(Color.gray)
          Circle().fill(Color.green).frame(width: 20, height: 20)
            .offset(x: central.lastLevelData?.yScaled(toContainerHeight: -geo.size.height) ?? 0,
                    y: central.lastLevelData?.xScaled(toContainerWidth: -geo.size.width) ?? 0)
          Path { path in
            path.move(to: CGPoint(x: geo.size.width/2, y: 0))
            path.addLine(to: CGPoint(x: geo.size.width/2, y: geo.size.height))
            path.move(to: CGPoint(x: 0, y: geo.size.height/2))
            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height/2))
          }
          .stroke(Color.purple, lineWidth: 1)

          Text("x").offset(x: -geo.size.width/2 + indexOffset, y: -indexOffset)
          Text("-15°").offset(x: -geo.size.width/2 + indexOffset, y: indexOffset)
          Text("15°").offset(x: geo.size.width/2 - indexOffset, y: indexOffset)

          Text("y").offset(x: -indexOffset, y: -geo.size.height/2 + indexOffset)
          Text("15°").offset(x: indexOffset, y: -geo.size.height/2 + indexOffset)
          Text("-15°").offset(x: indexOffset, y: geo.size.height/2 - indexOffset)
        }
        VStack {
          HStack {
            Text("x:")
            Spacer()
            Text("\(String(format: "%.01f°", -(central.lastLevelData?.yDegrees ?? 0)))")
          }
          HStack {
            Text("y:")
            Spacer()
            Text("\(String(format: "%.01f°", (central.lastLevelData?.xDegrees ?? 0)))")
          }
        }.frame(width: 80)
      }.aspectRatio(1.0, contentMode: .fit)
    }
    .padding()
  }
}


struct DiscoveryView_Previews: PreviewProvider {
  static var bman: BlueCentralManager = BlueCentralManager()

  static var previews: some View {
    DiscoveryView(central: bman)
  }
}

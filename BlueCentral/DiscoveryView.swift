
import SwiftUI
import BlueBase


struct DiscoveryView: View {
  @ObservedObject var central: BlueCentralManager

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
      HStack {
        Text("Message")
      }
    }
    .padding()
    .onAppear {
      let _ = central.central
    }
  }
}


struct DiscoveryView_Previews: PreviewProvider {
  static var bman: BlueCentralManager = BlueCentralManager()

  static var previews: some View {
    DiscoveryView(central: bman)
  }
}

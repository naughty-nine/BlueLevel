
import SwiftUI
import BlueBase


struct DiscoveryView: View {
  @ObservedObject var central: BlueCentralManager

  var body: some View {
    Text("Central role is scanning for peripherals")
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

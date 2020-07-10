
import SwiftUI
import BlueBase


struct AdvertisingView: View {
  @ObservedObject var peripheral: BluePeripheralManager

  var body: some View {
    Text("Peripheral role is advertising: \(PeripheralService.serviceName)")
      .onAppear {
        let a = peripheral.peripheral
        print(a.state)
      }
  }
}


struct AdvertisingView_Previews: PreviewProvider {
  static var peripheral = BluePeripheralManager()

  static var previews: some View {
    AdvertisingView(peripheral: peripheral)
  }
}

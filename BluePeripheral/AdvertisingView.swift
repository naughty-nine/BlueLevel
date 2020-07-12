
import SwiftUI
import BlueBase


struct AdvertisingView: View {
  @ObservedObject var peripheral: BluePeripheralManager

  var body: some View {
    VStack {
      Text("Peripheral service: \(PeripheralService.serviceName)")
      HStack {
        Text("Is advertising:")
        Toggle(isOn: peripheral.isAdvertisingBinding,
               label: { isAdvertisingLabel })
      }
      HStack {
        Text("Central:")
        Spacer()
        Text(peripheral.connectedCentralName)
      }
    }
    .padding()
  }

  var isAdvertisingLabel: some View {
    HStack {
      Spacer()
      Text(peripheral.isAdvertising ? "yes" : "no")
    }
  }
}


struct AdvertisingView_Previews: PreviewProvider {
  static var peripheral = BluePeripheralManager()

  static var previews: some View {
    AdvertisingView(peripheral: peripheral)
  }
}

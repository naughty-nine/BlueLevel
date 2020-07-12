# Bluetooth demo

App to explore the iOS Bluetooth stack.

Requirements: Xcode 12 beta 2, iOS 13

## Description

You need to iOS devices to run the full stack (MacOS not tested, but might very well work):

##### BluePeripheral

`BluePeripheral` contains an app playing the Bluetooth peripheral role.

It offers a service/characteristic to send a message upon connection to the characteristic.

Run this target on the 1st device. 

Upon start it runs a `CBPeripheralManager`  in discovery mode until a `CBCentralManager` connects. 

When a central connects to the advertised characteristic it stops advertising and sends a string message to to any connected central.

##### BlueCentral

`BlueCentral` contains an app playing the Bluetooth central role.

Run this target on a 2nd device.

Upon start it runs a `CBCentralManager` in scanning mode until it discovers a peripheral offering service/characteristic defined by `BluePeripheral`.

Once connected to a `BluePeripheral` it stops scanning and receives and displays the message sent from  the peripheral.

##### BlueBase

`BlueBase` contains a general Bluetooth framework and is included in both apps.


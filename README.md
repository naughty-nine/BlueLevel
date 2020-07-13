# Bluetooth demo

App to explore the iOS Bluetooth stack turning an iOS device into a bull's eye spirit level, a x-y dimensional spirit level that can be read remotely via Bluetooth on a 2nd iOS device or Mac.

Requirements: Xcode 12 beta 2, iOS/iPadOS 13, MacOS 15.5

## Description

You need two devices to run the full stack:

##### BluePeripheral

`BluePeripheral` contains an app playing the Bluetooth peripheral role.

It offers a service/characteristic to send a message upon connection to the characteristic.

Run this target on an iOS/iPadOS device supporting CoreMotion (gyroscopes).

Upon start it runs a `CBPeripheralManager`  in discovery mode until a `CBCentralManager` connects. 

When a central connects to the advertised characteristic it stops advertising and sends a string message to to any connected central.

After the initial message the peripheral turns on `CMMotionManger` and provides attitude data to the connected central.

##### BlueCentral

`BlueCentral` contains an app playing the Bluetooth central role.

Run this target on a 2nd device, either iOS/iPadOS or MacOS.

Upon start it runs a `CBCentralManager` in scanning mode until it discovers a peripheral offering service/characteristic defined by `BluePeripheral`.

Once connected to a `BluePeripheral` it stops scanning and receives and displays the message sent from  the peripheral.

If the message can be decoded to x-y attitude data this will shown as a bull's eye spirit level display.

##### BlueBase

`BlueBase` contains a general Bluetooth framework and is included in both apps.


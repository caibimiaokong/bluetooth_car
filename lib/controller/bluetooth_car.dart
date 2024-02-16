import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BluetoothCar extends GetxController {
  final isDarkMode = false.obs;
  BluetoothState bluetoothState = BluetoothState.STATE_OFF;
  final isBluetoothEnable = false.obs;
  final isPermissionGranted = false.obs;
  final isConnected = false.obs;
  BluetoothConnection? bluetoothConnection;
  final address = '1C:52:16:4E:BC:B4'.obs;
  final bluetooth = FlutterBluetoothSerial.instance;
  StreamSubscription<BluetoothDiscoveryResult>? streamSubscription;
  List<DropdownMenuItem<BluetoothDiscoveryResult>> results =
      List<DropdownMenuItem<BluetoothDiscoveryResult>>.empty().obs;
  final isDiscovering = false.obs;

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  //Check Whether Bluetooth is turned on
  void isBluetoothOn() async {
    // Retrieving the current Bluetooth state
    bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (bluetoothState == BluetoothState.STATE_OFF) {
      isBluetoothEnable.value = false;
    } else if (bluetoothState == BluetoothState.STATE_ON) {
      await startDisvover();
      isBluetoothEnable.value = true;
    }
  }

  //Get Device Info
  Future<int> getAndroidSdk() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  Future<bool> requestAccess() async {
    //request here your permissions

    bool permOne = await Permission.bluetoothScan.request().isGranted;
    bool permTwo = await Permission.bluetoothAdvertise.request().isGranted;
    bool permThree = await Permission.bluetoothConnect.request().isGranted;

    //This will only bring up one permission pop-up, but will only grant the permissions you have been requested here
    //in this method.

    //Return your boolean here
    return permOne && permTwo && permThree ? true : false;
  }

  void permissionRequest() async {
    if (Platform.isAndroid && await getAndroidSdk() > 30) {
      // It seems some manufacturer misimplement the bluetooth permissions
      // so I have added the request to Permission.bluetooth and inside
      // AndroidManifest.xml I have removed the android:maxSdkVersion="30".
      isPermissionGranted.value = await requestAccess();
    } else {
      isPermissionGranted.value =
          await Permission.bluetooth.request().isGranted;
    }
  }

  //switch bluetooth state
  Future switchBluetoothState(bool value) async {
    // If the Bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (value) {
      await bluetooth.requestEnable();
      await startDisvover();
    } else {
      await bluetooth.requestDisable();
      disconnectFromDevice();
      results.clear();
    }
  }

  //start discovering bluetooth devices
  Future<void> startDisvover() async {
    isDiscovering.value = true;
    streamSubscription = bluetooth.startDiscovery().listen((r) {
      debugPrint(r.device.name);
      results.add(
        DropdownMenuItem(
          value: r,
          onTap: () {
            address.value = r.device.address;
          },
          child: SizedBox(
            width: 200,
            height: 30,
            child: ListTile(
              title: Text(r.device.name ?? ''),
              subtitle: r.device.isBonded
                  ? const Text(
                      'Paired',
                      style: TextStyle(color: Colors.blueAccent),
                    )
                  : const Text(
                      'unPaired',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.signal_cellular_alt,
                    color: _computeTextStyle(r.rssi),
                  ),
                  Text(
                    r.rssi.toString(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    streamSubscription!.onDone(() {
      isDiscovering.value = false;
    });
  }

  static Color? _computeTextStyle(int rssi) {
    /**/ if (rssi >= -35) {
      return Colors.greenAccent[700];
    } else if (rssi >= -45) {
      return Color.lerp(
          Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10);
    } else if (rssi >= -55) {
      return Color.lerp(Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10);
    } else if (rssi >= -65) {
      return Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10);
    } else if (rssi >= -75) {
      return Color.lerp(
          Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10);
    } else if (rssi >= -85) {
      return Color.lerp(
          Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10);
    } else {
      /*code symetry*/
      return Colors.redAccent;
    }
  }

  void restartDiscovery() {
    results.clear();
    isDiscovering.value = true;

    startDisvover();
  }

  void connectToDevice() async {
    try {
      await BluetoothConnection.toAddress(address.value).then((connection) {
        bluetoothConnection = connection;
        isConnected.value = true;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void disconnectFromDevice() async {
    await bluetoothConnection?.close();
    isConnected.value = false;
  }

  void sendMessageToBluetooth(String val) async {
    bluetoothConnection?.output
        .add(Uint8List.fromList(utf8.encode("$val\r\n")));
    await bluetoothConnection?.output.allSent;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

class BluetoothCar extends GetxController {
  var bluetoothState = (BluetoothState.STATE_OFF).obs;
  final isSearching = false.obs;
  final isConnected = true.obs;
  late final BluetoothConnection connection;
  String defaultAddress = '1C:52:16:4E:BC:B4';
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDevice> devicesList = <BluetoothDevice>[].obs;
  List<BluetoothDiscoveryResult> results = <BluetoothDiscoveryResult>[].obs;
  final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  //Check Whether Bluetooth is turned on
  void isBluetoothON() async {
    try {
      bluetoothState.value = await FlutterBluetoothSerial.instance.state;
    } catch (e) {
      bluetoothState.value = BluetoothState.STATE_OFF;
    }
  }

  Future<bool> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    bluetoothState.value = await FlutterBluetoothSerial.instance.state;

    // If the Bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (bluetoothState.value == BluetoothState.STATE_OFF) {
      if (await FlutterBluetoothSerial.instance.requestEnable() ?? false) {
        await _getPairedDevices();
        return true;
      }
    } else if (bluetoothState.value == BluetoothState.STATE_ON) {
      await _getPairedDevices();
      return true;
    }
    return false;
  }

  //get paired devices
  Future<void> _getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      debugPrint("Error");
    }
    devicesList = devices;
  }

  //search for bluetooth devices
  void searchForDevices() async {
    isSearching.value = true;
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      results.add(r);
    });
    _streamSubscription!.onDone(() {
      isSearching.value = false;
    });
  }

  //stop searching for bluetooth devices
  void stopSearching() async {
    _streamSubscription?.cancel();
    isSearching.value = false;
  }

  //restart searching for bluetooth devices
  void restartSearching() async {
    _streamSubscription?.cancel();
    results.clear();
    searchForDevices();
  }

  //connect to the bluetooth device
  void connectToDevice({int? index}) async {
    try {
      connection = await BluetoothConnection.toAddress(
          index == null ? defaultAddress : results[index].device.address);
      if (index != null) {
        results[index] = BluetoothDiscoveryResult(
          device: BluetoothDevice(
              address: results[index].device.address,
              name: results[index].device.name,
              type: results[index].device.type,
              bondState: BluetoothBondState.bonded,
              isConnected: true),
          rssi: results[index].rssi,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //disconnect from the bluetooth device
  void disconnectFromDevice(int index) async {
    await connection.close();
    results[index] = BluetoothDiscoveryResult(
      device: BluetoothDevice(
          address: results[index].device.address,
          name: results[index].device.name,
          type: results[index].device.type,
          bondState: BluetoothBondState.bonded,
          isConnected: false),
      rssi: results[index].rssi,
    );
  }

  //bond the bluetooth device
  void bondDevice(int index) async {
    await FlutterBluetoothSerial.instance
        .bondDeviceAtAddress(results[index].device.address);
    results[index] = BluetoothDiscoveryResult(
      device: BluetoothDevice(
          address: results[index].device.address,
          name: results[index].device.name,
          type: results[index].device.type,
          bondState: BluetoothBondState.bonded),
      rssi: results[index].rssi,
    );
  }

  //unbond the bluetooth device
  void unbondDevice(int index) async {
    if (results[index].device.isConnected == true) {
      await connection.close();
    }
    await FlutterBluetoothSerial.instance
        .removeDeviceBondWithAddress(results[index].device.address);
    results[index] = BluetoothDiscoveryResult(
      device: BluetoothDevice(
          address: results[index].device.address,
          name: results[index].device.name,
          type: results[index].device.type,
          bondState: BluetoothBondState.none),
      rssi: results[index].rssi,
    );
  }

  //set the default bluetooth device
  void setDefaultDevice() {}
}

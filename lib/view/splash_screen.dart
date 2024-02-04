import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:bluetooth_car/controller/bluetooth_car.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final control = Get.find<BluetoothCar>();

  @override
  void initState() {
    super.initState();
    control.isBluetoothON();
    control.connectToDevice();
    Timer(const Duration(seconds: 5), () {
      control.bluetoothState.value.isEnabled
          ? control.connection.isConnected
              ? Get.offNamed('/control')
              : Get.offNamed('/control/search')
          : Get.offNamed('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(
      () => control.bluetoothState.value.isEnabled
          ? Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Lottie.asset('lib/configuration/asset/blueCar.json'),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Lottie.asset('lib/configuration/asset/searchBT.json'),
                ),
              ],
            )
          : Center(
              child: Column(
                children: [
                  Lottie.asset('lib/configuration/asset/switchBT.json'),
                  const Text('Please turn on the Bluetooth'),
                  Switch(
                    value: control.bluetoothState.value.isEnabled,
                    onChanged: (value) {
                      control.enableBluetooth();
                    },
                  )
                ],
              ),
            ),
    ));
  }
}

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
    control.isBluetoothOn();
    control.permissionRequest();
    Timer(const Duration(seconds: 5), () {
      if (control.isBluetoothEnable.value &&
          control.isPermissionGranted.value) {
        Get.offNamed('/control');
      }
    });
    //listen to bluetooth state change,if bluetooth is turned on, navigate to control screen
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      if (state == BluetoothState.STATE_ON) {
        control.isBluetoothEnable.value = true;
        Timer(const Duration(seconds: 5), () {
          // if (control.isPermissionGranted.value) {
          //   Get.offNamed('/control');
          // }
          Get.offNamed('/control');
        });
      }
      if (state == BluetoothState.STATE_OFF) {
        control.isBluetoothEnable.value = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Obx(
            () => control.isBluetoothEnable.value
                ? Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Lottie.asset(
                            'lib/configuration/asset/blueCar.json'),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Lottie.asset(
                            'lib/configuration/asset/searchBT.json'),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      children: [
                        Lottie.asset('lib/configuration/asset/switchBT.json'),
                        Text('toBLE'.tr),
                      ],
                    ),
                  ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'created by @caibimiaokong',
                style: TextStyle(color: Colors.grey.shade500),
              ))
        ]));
  }
}

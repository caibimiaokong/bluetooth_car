import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:get/get.dart';
import 'package:kdgaugeview/kdgaugeview.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:lottie/lottie.dart';

import 'package:bluetooth_car/units/units.dart';
import 'package:bluetooth_car/controller/bluetooth_car.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  String initCommand = 'Vf';
  bool isAccelerateTap = false;
  bool isHornTap = false;
  String language = 'English';
  bool isAnimationPlay = false;
  BluetoothDiscoveryResult? bluetoothDevice;
  final control = Get.find<BluetoothCar>();

  GlobalKey<KdGaugeViewState> key = GlobalKey<KdGaugeViewState>();
  final speedNotifier = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    control.startDisvover();
    //Hide the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      if (state == BluetoothState.STATE_ON) {
        control.isBluetoothEnable.value = true;
      } else if (state == BluetoothState.STATE_OFF) {
        control.isBluetoothEnable.value = false;
        control.disconnectFromDevice();
        Get.offNamed('/');
      }
    });
  }

  @override
  void dispose() {
    //Show the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    control.streamSubscription?.cancel();
    super.dispose();
  }

  void sendSingleCommand(String command) {
    if (command != initCommand) {
      control.sendMessageToBluetooth(command);
      initCommand = command;
      debugPrint('Send command: $command');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          //Orientation control
          Positioned(
            left: 60,
            bottom: 50,
            child: SizedBox(
                width: 150,
                height: 150,
                child: Joystick(listener: (details) {
                  double x = details.x;
                  double y = details.y;
                  if (y < -2.414 * x && y < 2.414 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });

                    sendSingleCommand('W');
                    if (isAccelerateTap) {
                      key.currentState?.updateSpeed(255);
                      speedNotifier.value = 255;
                    } else {
                      key.currentState?.updateSpeed(160);
                      speedNotifier.value = 160;
                    }
                    // if (isAccelerateTap) {
                    //   sendSingleCommand('F');
                    //   key.currentState?.updateSpeed(255);
                    //   speedNotifier.value = 255;
                    // } else {
                    //   sendSingleCommand('W');
                    //   key.currentState?.updateSpeed(160);
                    //   speedNotifier.value = 160;
                    // }
                  }
                  if (y > -2.414 * x && y > 2.414 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    sendSingleCommand('X');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                  }
                  if (0.41 * x < y && y < -0.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    sendSingleCommand('A');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                  }
                  if (-0.41 * x < y && y < 0.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    sendSingleCommand('D');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                  }
                  if (y == 0 && x == 0) {
                    setState(() {
                      isAnimationPlay = false;
                    });
                    sendSingleCommand('S');
                    key.currentState?.updateSpeed(0);
                    speedNotifier.value = 0;
                  }
                  if (y > 2.41 * x && y < 0.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    sendSingleCommand('Q');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                  }
                  if (y > -2.41 * x && y < -0.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    sendSingleCommand('E');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                  }
                  if (y > -0.41 * x && y < -2.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    sendSingleCommand('Z');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                  }
                  if (y > 0.41 * x && y < 2.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    sendSingleCommand('C');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                  }
                })),
          ),

          //Acceleration button
          Positioned(
              right: 110,
              bottom: 90,
              child: GestureDetector(
                child: Obx(() => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: control.isDarkMode.value
                            ? Colors.grey.shade500
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_circle_up,
                          size: 60,
                          color:
                              isAccelerateTap ? Colors.blue : Colors.black45),
                    )),
                onLongPress: () {
                  setState(() {
                    isAccelerateTap = !isAccelerateTap;
                  });
                },
                onLongPressEnd: (details) {
                  setState(() {
                    isAccelerateTap = !isAccelerateTap;
                  });
                },
              )),

          //horn button
          Positioned(
              right: 70,
              bottom: 200,
              child: GestureDetector(
                onTapUp: (details) {
                  setState(() {
                    isHornTap = !isHornTap;
                  });
                },
                onTapDown: (details) {
                  setState(() {
                    isHornTap = !isHornTap;
                    control.sendMessageToBluetooth('H');
                  });
                },
                child: Obx(() => Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: control.isDarkMode.value
                            ? Colors.grey.shade500
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.volume_up,
                          size: 50,
                          color: isHornTap ? Colors.blue : Colors.black45),
                    )),
              )),

          //language button ,theme change button
          Positioned(
            left: 150,
            top: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.language,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            title: Text(
                              'language'.tr,
                            ),
                            children: [
                              SimpleDialogOption(
                                onPressed: () {
                                  Get.updateLocale(const Locale('zh', 'CN'));
                                  setState(() {
                                    language = 'Chinese';
                                  });
                                  Get.back();
                                },
                                child: Text(
                                  '简体中文',
                                  style: TextStyle(
                                      color: language == 'Chinese'
                                          ? Colors.blueAccent
                                          : Colors.blueGrey),
                                ),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Get.updateLocale(const Locale('en', 'US'));
                                  setState(() {
                                    language = 'English';
                                  });
                                  Get.back();
                                },
                                child: Text(
                                  'English',
                                  style: TextStyle(
                                      color: language == 'English'
                                          ? Colors.blueAccent
                                          : Colors.blueGrey),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                ),
                Obx(() => DayNightSwitcher(
                      isDarkModeEnabled: control.isDarkMode.value,
                      onStateChanged: (isDarkModeEnabled) {
                        control.toggleDarkMode();
                      },
                    )),
              ],
            ),
          ),

          //instrument panel
          Center(
            child: Container(
                width: 360,
                height: 360,
                padding: const EdgeInsets.all(10),
                child: ValueListenableBuilder<double>(
                    valueListenable: speedNotifier,
                    builder: (context, value, child) {
                      return KdGaugeView(
                        key: key,
                        unitOfMeasurement: "MPH",
                        speedTextStyle: TextStyle(
                          fontSize: 60,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 6
                            ..color = Colors.greenAccent,
                        ),
                        minSpeed: 0,
                        maxSpeed: 255,
                        speed: 0,
                        animate: true,
                        alertSpeedArray: const [80, 160, 255],
                        alertColorArray: const [
                          Colors.orange,
                          Colors.indigo,
                          Colors.red
                        ],
                        duration: const Duration(seconds: 6),
                        child: //Background animation
                            Lottie.asset('lib/configuration/asset/redCar.json',
                                animate: isAnimationPlay),
                      );
                    })),
          ),
          //Bluetooth switch ,choose list, connect button
          Positioned(
            right: 30,
            top: 10,
            child: Row(
              children: [
                Obx(() => DropdownButton<BluetoothDiscoveryResult>(
                      items: control.results,
                      value: control.results.isEmpty ? null : bluetoothDevice,
                      onChanged: (value) {
                        setState(() {
                          bluetoothDevice = value;
                        });
                      },
                    )),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    control.restartDiscovery();
                  },
                ),
                Obx(() => ElevatedButton(
                    onPressed: () {
                      control.isConnected.value
                          ? control.disconnectFromDevice()
                          : control.connectToDevice();
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      backgroundColor: control.isConnected.value
                          ? MaterialStateProperty.all<Color>(Colors.blue)
                          : MaterialStateProperty.all<Color>(Colors.blueGrey),
                    ),
                    child: control.isConnected.value
                        ? Text('connected'.tr)
                        : Text('disconnected'.tr))),
              ],
            ),
          ),
        ],
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: ExpandableFab(
        distance: 90,
        children: [
          ActionButton(
            onPressed: () {
              control.sendMessageToBluetooth('N');
            },
            icon: const Icon(Icons.skip_next),
          ),
          ActionButton(
            onPressed: () => control.sendMessageToBluetooth('I'),
            icon: const Icon(Icons.volume_up),
          ),
          ActionButton(
            onPressed: () => control.sendMessageToBluetooth('O'),
            icon: const Icon(Icons.volume_down),
          ),
          ActionButton(
            onPressed: () => control.sendMessageToBluetooth('P'),
            icon: const Icon(Icons.skip_previous),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (details) {},
      onTapUp: (details) {},
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        width: 40,
        height: 40,
        child: IconButton(
          onPressed: widget.onPressed,
          icon: widget.icon,
          color: theme.colorScheme.onSecondary,
        ),
      ),
    );
  }
}

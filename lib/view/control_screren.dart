import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

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
  String item = 'Device 1';
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
    debugPrint(control.results.toString());
    //Hide the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      if (state == BluetoothState.STATE_ON) {
        control.isBluetoothEnable.value = true;
      } else if (state == BluetoothState.STATE_OFF) {
        control.isBluetoothEnable.value = false;
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
                    if (isAccelerateTap) {
                      control.sendMessageToBluetooth('F');
                      key.currentState?.updateSpeed(255);
                      speedNotifier.value = 255;
                      debugPrint('Accelerate');
                    } else {
                      control.sendMessageToBluetooth('W');
                      key.currentState?.updateSpeed(160);
                      speedNotifier.value = 160;
                      debugPrint('Forward');
                    }
                  }
                  if (y > -2.414 * x && y > 2.414 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    control.sendMessageToBluetooth('X');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                    debugPrint('Backward');
                  }
                  if (0.41 * x < y && y < -0.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    control.sendMessageToBluetooth('A');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                    debugPrint('Left');
                  }
                  if (-0.41 * x < y && y < 0.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    control.sendMessageToBluetooth('D');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                    debugPrint('Right');
                  }
                  if (y == 0 && x == 0) {
                    setState(() {
                      isAnimationPlay = false;
                    });
                    control.sendMessageToBluetooth('S');
                    key.currentState?.updateSpeed(0);
                    speedNotifier.value = 0;
                    debugPrint('Stop');
                  }
                  if (y > 2.41 * x && y < 0.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    control.sendMessageToBluetooth('Q');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                    debugPrint('Left Forward');
                  }
                  if (y > -2.41 * x && y < -0.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    control.sendMessageToBluetooth('E');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                    debugPrint('Right Forward');
                  }
                  if (y > -0.41 * x && y < -2.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    control.sendMessageToBluetooth('Z');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                    debugPrint('Left Backward');
                  }
                  if (y > 0.41 * x && y < 2.41 * x) {
                    setState(() {
                      isAnimationPlay = true;
                    });
                    control.sendMessageToBluetooth('C');
                    key.currentState?.updateSpeed(255);
                    speedNotifier.value = 255;
                    debugPrint('Right Backward');
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
                  control.sendMessageToBluetooth('F');
                },
                onLongPressEnd: (details) {
                  setState(() {
                    isAccelerateTap = !isAccelerateTap;
                  });
                  control.sendMessageToBluetooth('W');
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
                        unitOfMeasurement: "MPH",
                        speedTextStyle: TextStyle(
                          fontSize: 100,
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
                        child: Lottie.asset(
                            'lib/configuration/asset/redCar.json',
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
                        : Text('disconnected'.tr)))
              ],
            ),
          ),
        ],
      )),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () => _showAction(context, 0),
            icon: const Icon(Icons.format_size),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 1),
            icon: const Icon(Icons.insert_photo),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 2),
            icon: const Icon(Icons.videocam),
          ),
        ],
      ),
      /////////////
      /////////////
      /////////////
      ///add this line
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  static const _actionTitles = ['Create Post', 'Upload Photo', 'Upload Video'];

  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment
            .topLeft, //modify this line,change the position of the button
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0,
            angleInDegrees =
                180.0; //expaned button position from topleft to bottomright
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.topLeft,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.create),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:bluetooth_car/controller/bluetooth_car.dart';

// ignore: must_be_immutable
class FoldButton extends StatelessWidget {
  FoldButton({
    super.key,
  });

  final control = Get.find<BluetoothCar>();
  bool isNextPress = false;
  bool isPreviousPress = false;
  bool isIncreasePress = false;
  bool isDecreasePress = false;

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      distance: 80,
      children: [
        //next button
        ActionButton(
          onPressed: () {
            debugPrint('next');
            control.sendMessageToBluetooth('N');
          },
          isPress: isNextPress,
          icon: Icons.skip_next,
        ),

        //increase sound button
        ActionButton(
          onPressed: () {
            debugPrint('increase');
            control.sendMessageToBluetooth('I');
          },
          isPress: isIncreasePress,
          icon: Icons.volume_up,
        ),

        //decrease sound button
        ActionButton(
          onPressed: () {
            debugPrint('decrease');
            control.sendMessageToBluetooth('D');
          },
          isPress: isDecreasePress,
          icon: Icons.volume_down,
        ),

        //previous button
        ActionButton(
          onPressed: () {
            debugPrint('previous');
            control.sendMessageToBluetooth('P');
          },
          isPress: isPreviousPress,
          icon: Icons.skip_previous,
        ),
      ],
    );
  }
}

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
    return SizedBox(
      width: 50,
      height: 50,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.topLeft,
          clipBehavior: Clip.none,
          children: [
            _buildTapToCloseFab(),
            ..._buildExpandingActionButtons(),
            _buildTapToOpenFab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          color: Colors.white60,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close, color: Colors.blue),
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
    for (var i = 0, angleInDegrees = 180.0;
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
          child: SizedBox(
            width: 40,
            height: 40,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: _toggle,
              child: const Icon(Icons.music_note),
            ),
          ),
        ),
      ),
    );
  }
}

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

// ignore: must_be_immutable
class ActionButton extends StatefulWidget {
  ActionButton({
    super.key,
    this.onPressed,
    required this.isPress,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  bool isPress;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          widget.isPress = !widget.isPress;
          widget.onPressed!();
        });
      },
      onTapUp: (details) {
        widget.isPress = !widget.isPress;
      },
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        color: Colors.white60,
        elevation: 4,
        child: Icon(widget.icon,
            color: widget.isPress ? Colors.blue : Colors.grey, size: 30),
      ),
    );
  }
}

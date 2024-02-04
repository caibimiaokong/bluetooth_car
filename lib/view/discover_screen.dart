import 'package:bluetooth_car/controller/bluetooth_car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final control = Get.find<BluetoothCar>();

  @override
  void initState() {
    super.initState();
    control.searchForDevices();
  }

  @override
  void dispose() {
    control.stopSearching();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Obx(
            () => control.isSearching.value
                ? const Text('Discovering Devices')
                : const Text('Discovered Devices'),
          ),
          actions: <Widget>[
            Obx(() => control.isSearching.value
                ? FittedBox(
                    child: Container(
                      margin: const EdgeInsets.all(16.0),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.replay),
                    onPressed: control.restartSearching,
                  ))
          ],
        ),
        body: Obx(
          () => control.results.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: control.results.length,
                  itemBuilder: (context, index) {
                    BluetoothDiscoveryResult result = control.results[index];
                    return ListTile(
                        leading: const Icon(Icons.devices),
                        isThreeLine: true,
                        title: Text(result.device.name ?? "Unknown device"),
                        subtitle: Column(
                          children: [
                            Text(result.device.address.toString()),
                            result.device.isBonded
                                ? const Text('Connected')
                                : const Text('Not Connected'),
                          ],
                        ),
                        trailing: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  if (result.device.isConnected) {
                                    control.disconnectFromDevice(index);
                                  } else {
                                    if (result.device.isBonded) {
                                      control.connectToDevice(index: index);
                                    } else {
                                      Get.snackbar(
                                          'Error', 'Device is not bonded');
                                    }
                                  }
                                },
                                icon: result.device.isConnected
                                    ? const Icon(
                                        Icons.import_export,
                                        color: Colors.blue,
                                      )
                                    : const Icon(Icons.import_export)),
                            IconButton(
                              icon: const Icon(Icons.link),
                              onPressed: () {
                                if (result.device.isBonded) {
                                  control.unbondDevice(index);
                                } else {
                                  control.bondDevice(index);
                                }
                              },
                            ),
                          ],
                        ));
                  },
                ),
        ));
  }
}

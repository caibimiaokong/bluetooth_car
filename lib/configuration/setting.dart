import 'package:get/get.dart';

import 'package:bluetooth_car/view/view.dart';

class ConstSetting {
  static final router = [
    GetPage(
      name: '/',
      page: () => const SplashScreen(),
    ),
    GetPage(name: '/control', page: () => const ControlScreen(), children: [
      GetPage(
        name: '/search',
        page: () => const DiscoverScreen(),
      ),
    ]),
  ];
}

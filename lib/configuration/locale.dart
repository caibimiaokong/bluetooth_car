import 'package:get/get.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'connect': 'Connnect',
          'disconnect': 'disconnect',
          'language': 'Language',
          'toBLE': 'Please turn on the Bluetooth',
          'connected': 'Connected',
          'disconnected': 'Unconnected',
        },
        'zh_CN': {
          'connect': '连接',
          'disconnect': '断开',
          'language': '语言',
          'toBLE': '请打开蓝牙',
          'connected': '已连接',
          'disconnected': '未连接',
        },
      };
}

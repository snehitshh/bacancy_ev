import 'package:flutter/services.dart';

class NativeSerialPort {
  static const MethodChannel _channel = MethodChannel('serial_port');

  static Future<List<String>> getAllDevices() async {
    final List<dynamic> devices = await _channel.invokeMethod('getAllDevices');
    return devices.cast<String>();
  }

  static Future<List<String>> getAllDevicesPath() async {
    final List<dynamic> paths = await _channel.invokeMethod('getAllDevicesPath');
    return paths.cast<String>();
  }

  static Future<bool> isDeviceAccessible(String devicePath) async {
    return await _channel.invokeMethod('isDeviceAccessible', {'devicePath': devicePath});
  }

  static Future<Map<String, dynamic>?> getDeviceInfo(String devicePath) async {
    final Map<dynamic, dynamic>? info = await _channel.invokeMethod('getDeviceInfo', {'devicePath': devicePath});
    return info?.cast<String, dynamic>();
  }

  static Future<bool> openPort(String devicePath, int baudrate) async {
    return await _channel.invokeMethod('openPort', {
      'devicePath': devicePath,
      'baudrate': baudrate,
    });
  }

  static Future<List<int>?> readData() async {
    final data = await _channel.invokeMethod('readData');
    if (data == null) return null;
    return List<int>.from(data);
  }
} 
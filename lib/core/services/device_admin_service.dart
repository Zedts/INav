import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceAdminService {
  static const MethodChannel _channel = MethodChannel('com.zedt.inav/device_admin');

  static Future<bool> isDeviceAdminEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDeviceAdminEnabled');
      return result ?? false;
    } catch (e) {
      debugPrint('DeviceAdminService: Error checking device admin - $e');
      return false;
    }
  }

  static Future<bool> requestDeviceAdmin() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestDeviceAdmin');
      return result ?? false;
    } catch (e) {
      debugPrint('DeviceAdminService: Error requesting device admin - $e');
      return false;
    }
  }

  static Future<bool> removeDeviceAdmin() async {
    try {
      final result = await _channel.invokeMethod<bool>('removeDeviceAdmin');
      return result ?? false;
    } catch (e) {
      debugPrint('DeviceAdminService: Error removing device admin - $e');
      return false;
    }
  }
}

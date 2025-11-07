import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/utils/logger.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'healthcare_app',
    ),
  );

  static Future<void> init() async {
    try {
      // Test storage availability
      await _storage.containsKey(key: 'test');
      AppLogger.d('Secure storage initialized successfully');
    } catch (e) {
      AppLogger.e('Failed to initialize secure storage', e);
      throw CacheException(
        message: 'Failed to initialize secure storage',
        originalException: e,
      );
    }
  }

  /// Store a string value
  static Future<void> setString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.d('Stored value for key: $key');
    } catch (e) {
      AppLogger.e('Failed to store value for key: $key', e);
      throw CacheException(
        message: 'Failed to store secure data',
        originalException: e,
      );
    }
  }

  /// Retrieve a string value
  static Future<String?> getString(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) {
        AppLogger.d('Retrieved value for key: $key');
      }
      return value;
    } catch (e) {
      AppLogger.e('Failed to retrieve value for key: $key', e);
      throw CacheException(
        message: 'Failed to retrieve secure data',
        originalException: e,
      );
    }
  }

  /// Store a boolean value
  static Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }

  /// Retrieve a boolean value
  static Future<bool?> getBool(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Store an integer value
  static Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  /// Retrieve an integer value
  static Future<int?> getInt(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Store a double value
  static Future<void> setDouble(String key, double value) async {
    await setString(key, value.toString());
  }

  /// Retrieve a double value
  static Future<double?> getDouble(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  /// Check if a key exists
  static Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      AppLogger.e('Failed to check key existence: $key', e);
      return false;
    }
  }

  /// Delete a specific key
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.d('Deleted key: $key');
    } catch (e) {
      AppLogger.e('Failed to delete key: $key', e);
      throw CacheException(
        message: 'Failed to delete secure data',
        originalException: e,
      );
    }
  }

  /// Delete all stored data
  static Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.d('Deleted all secure storage data');
    } catch (e) {
      AppLogger.e('Failed to delete all secure storage data', e);
      throw CacheException(
        message: 'Failed to clear secure storage',
        originalException: e,
      );
    }
  }

  /// Get all keys
  static Future<Map<String, String>> getAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      AppLogger.e('Failed to retrieve all secure storage data', e);
      throw CacheException(
        message: 'Failed to retrieve all secure data',
        originalException: e,
      );
    }
  }

  /// Store multiple key-value pairs
  static Future<void> setMultiple(Map<String, String> data) async {
    try {
      for (final entry in data.entries) {
        await _storage.write(key: entry.key, value: entry.value);
      }
      AppLogger.d('Stored ${data.length} key-value pairs');
    } catch (e) {
      AppLogger.e('Failed to store multiple values', e);
      throw CacheException(
        message: 'Failed to store multiple secure values',
        originalException: e,
      );
    }
  }

  /// Delete multiple keys
  static Future<void> deleteMultiple(List<String> keys) async {
    try {
      for (final key in keys) {
        await _storage.delete(key: key);
      }
      AppLogger.d('Deleted ${keys.length} keys');
    } catch (e) {
      AppLogger.e('Failed to delete multiple keys', e);
      throw CacheException(
        message: 'Failed to delete multiple secure keys',
        originalException: e,
      );
    }
  }
}
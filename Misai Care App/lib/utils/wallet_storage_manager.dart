import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class WalletStorageManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
      iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    ),

  );

  static const String _walletAddressKey = 'wallet_address';
  static const String _didKey = 'did_key';
  static const String _abhaNumberKey = 'abha_number';
  static const String _isWalletConnectedKey = 'is_wallet_connected';
  static const String _userProfileKey = 'user_profile';

  /// Store wallet information securely
  static Future<void> storeWalletInfo({
    required String walletAddress,
    required String did,
    required String abhaNumber,
    Map<String, dynamic>? userProfile,
  }) async {
    try {
      await _storage.write(key: _walletAddressKey, value: walletAddress);
      await _storage.write(key: _didKey, value: did);
      await _storage.write(key: _abhaNumberKey, value: abhaNumber);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isWalletConnectedKey, true);

      if (userProfile != null) {
        await prefs.setString(_userProfileKey, json.encode(userProfile));
      }

      debugPrint('Wallet info stored successfully');
    } catch (e) {
      debugPrint('Error storing wallet info: $e');
    }
  }

  /// Retrieve stored wallet information
  static Future<Map<String, dynamic>?> getStoredWalletInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isConnected = prefs.getBool(_isWalletConnectedKey) ?? false;

      if (!isConnected) {
        return null;
      }

      final walletAddress = await _storage.read(key: _walletAddressKey);
      final did = await _storage.read(key: _didKey);
      final abhaNumber = await _storage.read(key: _abhaNumberKey);
      final userProfileJson = prefs.getString(_userProfileKey);

      if (walletAddress != null && did != null && abhaNumber != null) {
        return {
          'walletAddress': walletAddress,
          'did': did,
          'abhaNumber': abhaNumber,
          'userProfile':
              userProfileJson != null ? json.decode(userProfileJson) : null,
          'isConnected': true,
        };
      }
    } catch (e) {
      debugPrint('Error retrieving wallet info: $e');
    }
    return null;
  }

  /// Check if wallet is connected
  static Future<bool> isWalletConnected() async {
    final walletInfo = await getStoredWalletInfo();
    return walletInfo != null && walletInfo['isConnected'] == true;
  }

  static Future<void> clearWalletData() async {
    try {
      await _storage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isWalletConnectedKey);
      await prefs.remove(_userProfileKey);
      debugPrint('Wallet data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing wallet data: $e');
    }
  }
}

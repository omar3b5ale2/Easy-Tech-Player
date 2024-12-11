
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';

final key = encrypt.Key.fromUtf8('1234567890abcdef1234567890abcdef');  // 256-bit key (32 bytes)
final iv = encrypt.IV.fromUtf8('abcdef9876543210');  // 128-bit IV (16 bytes)

class EncryptionService {

  EncryptionService();

  /// Decrypts the encrypted data and returns the decoded JSON map
  Map<String, dynamic>? decryptAndExtractData(String encryptedData) {
    try {
      final decryptedString = decryptData(encryptedData);
      return jsonDecode(decryptedString);
    } catch (e) {
      debugPrint("Error decrypting data: $e");
      return null;
    }
  }

  /// Decrypts data using AES encryption with the provided AES key
  String decryptData(String encryptedData) {
    // Convert base64-encoded values back to their original binary format
    final encrypted = encrypt.Encrypted.fromBase64(encryptedData);

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // Decrypt the data
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    // Return the decrypted data (which is JSON)
    return decrypted;
  }
}


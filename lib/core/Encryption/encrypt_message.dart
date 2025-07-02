
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class MessageEncryption {
  final encrypt.Encrypter _encrypter;
  final encrypt.Key _key;
  MessageEncryption(String encryptionKey)
      : _key = encrypt.Key.fromUtf8(_normalizeKey(encryptionKey)),
        _encrypter = encrypt.Encrypter(
          encrypt.AES(
            encrypt.Key.fromUtf8(_normalizeKey(encryptionKey)),
            mode: encrypt.AESMode.cbc,
            padding: 'PKCS7',
          ),
        );

  static String _normalizeKey(String key) {
    if (key.length > 32) return key.substring(0, 32);
    return key.padRight(32, '0');
  }
  String encryptText(String plaintext) {
    if (plaintext.isEmpty) return '';
    try {
      final iv = encrypt.IV.fromSecureRandom(16); // 128-bit IV
      final encrypted = _encrypter.encrypt(plaintext, iv: iv);
      return base64Encode(iv.bytes + encrypted.bytes);
    } catch (e) {
      print('Encryption error: $e');
      return '';
    }
  }

  String decryptText(String base64Ciphertext) {
    if (base64Ciphertext.isEmpty) return '';
    try {
      final combined = base64Decode(base64Ciphertext);
      if (combined.length < 16) throw FormatException('Invalid ciphertext length');
      final iv = encrypt.IV(Uint8List.fromList(combined.sublist(0, 16)));
      final ciphertext = combined.sublist(16);
      final encrypted = encrypt.Encrypted(Uint8List.fromList(ciphertext));
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print('Decryption error: $e');
      return '[Decryption failed]';
    }
  }
  Future<Uint8List> encryptFile(File file) async {
    final fileBytes = await file.readAsBytes();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(fileBytes, iv: iv);
    return Uint8List.fromList(iv.bytes + encrypted.bytes);
  }
  Uint8List decryptFile(Uint8List encryptedData) {
    if (encryptedData.length < 16) throw FormatException('Invalid encrypted data length');
    final iv = encrypt.IV(Uint8List.fromList(encryptedData.sublist(0, 16)));
    final ciphertext = encryptedData.sublist(16);
    final encrypted = encrypt.Encrypted(Uint8List.fromList(ciphertext));
    return Uint8List.fromList(_encrypter.decryptBytes(encrypted, iv: iv));
  }
}
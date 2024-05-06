import 'dart:convert';
import 'dart:typed_data';
import 'package:blowfish_cbc/src/blowfish_cbc.dart';

class BlowfishCBCUtil {
  static String encrypt(String message, String key, {Uint8List? iv}) {
    final blowfish = BlowfishCBC(Uint8List.fromList(utf8.encode(key)), iv: iv);
    // Add PKCS5 padding.
    final encrypt = padPKCS5(utf8.encode(message));
    final encryptedData = blowfish.encode(encrypt);
    return base64.encode(encryptedData);
  }

  static String decrypt(String encrypted, String key, {Uint8List? iv}) {
    final blowfish = BlowfishCBC(Uint8List.fromList(utf8.encode(key)), iv: iv);
     var decryptedData = blowfish.decode(base64.decode(encrypted));
    // Remove PKCS5 padding.
    decryptedData = unpadPKCS5(Uint8List.fromList(decryptedData));
    return utf8.decode(decryptedData);
  }

  static Uint8List padPKCS5(List<int> input) {
    final inputLength = input.length;
    final paddingValue = 8 - (inputLength % 8);
    final outputLength = inputLength + paddingValue;

    final output = Uint8List(outputLength);
    for (var i = 0; i < inputLength; ++i) {
      output[i] = input[i];
    }
    output.fillRange(outputLength - paddingValue, outputLength, paddingValue);

    return output;
  }

  // // Remove padding PKCS5
  static Uint8List unpadPKCS5(Uint8List paddedData) {
    final paddingLength = paddedData.last;
    if (paddingLength < 1 || paddingLength > 8) {
      throw const FormatException('Invalid padding length.');
    }
    
    for (int i = paddedData.length - paddingLength; i < paddedData.length; i++) {
      if (paddedData[i] != paddingLength) {
        throw const FormatException('Invalid PKCS5 padding.');
      }
    }

    return Uint8List.sublistView(paddedData, 0, paddedData.length - paddingLength);
  }
}

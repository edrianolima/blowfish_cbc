import 'dart:convert';
import 'dart:typed_data';

import 'package:blowfish_cbc/src/tables.dart';
import 'package:blowfish_cbc/src/blowfish_cbc_converter.dart';

/// A Blowfish CBC [Codec] implementation.
class BlowfishCBC extends Codec<List<int>, List<int>> {
  static const blockSize = 8; // Blowfish block size

  final List<int> _p = copyP(pInit);
  final List<List<int>> _s = copyS(sInit);
  late Uint8List _iv;

  /// A [Converter] that encrypts data.
  @override
  Converter<List<int>, Uint8List> get encoder => BlowfishCBCEncoder(_p, _s, _iv);

  /// A [Converter] that decrypts data.
  @override
  Converter<List<int>, Uint8List> get decoder => BlowfishCBCDecoder(_p, _s, _iv);

  /// Creates an instance of the codec initialized with the given [key] and optional [iv].
  BlowfishCBC(Uint8List key, {Uint8List? iv}) {
    if (key.length > 56) {
      throw FormatException('Max key length is 448 bits (56 bytes)', key);
    }
    _iv = iv ?? _generateIVFromKey(key);
    _initializeKey(key);
  }

  Uint8List _generateIVFromKey(Uint8List key) {
    return Uint8List.sublistView(key, 0, blockSize);
  }

  void _initializeKey(Uint8List key) {
    var j = 0;
    for (var i = 0; i < _p.length; ++i) {
      var data = 0;
      for (var k = 0; k < 4; ++k) {
        data = ((data << 8) & 0xffffffff) | key[j];
        j = (j + 1) % key.length;
      }
      _p[i] ^= data;
    }

    var data = Uint8List(8);
    for (var i = 0; i < _p.length; i += 2) {
      BlowfishCBCEncoder.encryptBlock(data, 0, _p, _s);
      _p[i] = (data[0] << 24) + (data[1] << 16) + (data[2] << 8) + data[3];
      _p[i + 1] = (data[4] << 24) + (data[5] << 16) + (data[6] << 8) + data[7];
    }

    for (var i = 0; i < 4; ++i) {
      for (var j = 0; j < 256; j += 2) {
        BlowfishCBCEncoder.encryptBlock(data, 0, _p, _s);
        _s[i][j] = (data[0] << 24) + (data[1] << 16) + (data[2] << 8) + data[3];
        _s[i][j + 1] = (data[4] << 24) + (data[5] << 16) + (data[6] << 8) + data[7];
      }
    }
  }
}

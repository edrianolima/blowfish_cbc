import 'dart:convert';
import 'dart:typed_data';

import 'package:blowfish_cbc/src/blowfish_cbc.dart';
import 'package:meta/meta.dart';

abstract class BlowfishCBCConverter extends Converter<List<int>, Uint8List> {
  /// A base P list initialized with the key.
  final List<int> p;

  /// A base S list initialized with the key.
  final List<List<int>> s;
  final Uint8List iv;

  BlowfishCBCConverter(this.p, this.s, this.iv);

  /// Encrypts or decrypts the given [input], returning a new [Uint8List] with
  /// the output.
  @override
  Uint8List convert(List<int> input) {
    final result = Uint8List(input.length);
    Uint8List previousBlock = Uint8List.fromList(iv);

    for (var start = 0; start < input.length; start += 8) {
      Uint8List block = Uint8List.fromList(input.sublist(start, start + 8));
      // XOR current block with the previous encrypted block
      for (int i = 0; i < 8; i++) {
        block[i] ^= previousBlock[i];
      }
      _transformBlock(block, 0, p, s);
      result.setRange(start, start + 8, block);
      previousBlock = block;
    }

    return result;
  }

  @protected
  void _transformBlock(
    Uint8List data,
    int startIndex,
    List<int> p,
    List<List<int>> s,
  );

  static void _transformBlockCommon({
    required Uint8List data,
    required int startIndex,
    required List<int> p,
    required List<List<int>> s,
    required int loopStartAt,
    required int looopStopBefore,
    required int loopStep,
  }) {
    var bL = (data[0 + startIndex] << 24) +
        (data[1 + startIndex] << 16) +
        (data[2 + startIndex] << 8) +
        data[3 + startIndex];
    var bR = (data[4 + startIndex] << 24) +
        (data[5 + startIndex] << 16) +
        (data[6 + startIndex] << 8) +
        data[7 + startIndex];

    for (var i = loopStartAt; i != looopStopBefore; i += loopStep) {
      bL ^= p[i];
      bR ^= _feistel(bL, s);

      final swap = bL;
      bL = bR;
      bR = swap;
    }

    final swap = bL;
    bL = bR;
    bR = swap;

    bR ^= p[looopStopBefore];
    bL ^= p[looopStopBefore + loopStep];

    data[0 + startIndex] = bL >> 24;
    data[1 + startIndex] = bL >> 16;
    data[2 + startIndex] = bL >> 8;
    data[3 + startIndex] = bL;
    data[4 + startIndex] = bR >> 24;
    data[5 + startIndex] = bR >> 16;
    data[6 + startIndex] = bR >> 8;
    data[7 + startIndex] = bR;
  }

  static int _feistel(int x, List<List<int>> s) {
    var _x = x;
    final d = _x & 0xff;
    _x >>= 8;
    final c = _x & 0xff;
    _x >>= 8;
    final b = _x & 0xff;
    _x >>= 8;
    final a = _x & 0xff;
    var y = (s[0][a] + s[1][b]) & 0xffffffff;
    y ^= s[2][c];
    y = (y + s[3][d]) & 0xffffffff;
    return y;
  }
}

class BlowfishCBCEncoder extends BlowfishCBCConverter {
  BlowfishCBCEncoder(List<int> p, List<List<int>> s, Uint8List iv) : super(p, s, iv);

  @override
  void _transformBlock(
    Uint8List data, 
    int startIndex, 
    List<int> p, 
    List<List<int>> s,
  ) =>
      encryptBlock(data, startIndex, p, s);

  /// Encrypts an 8-byte block of data in an existing list of [data], starting
  /// at [startIndex].
  ///
  /// This is used internally by the package and should not need to be called in
  /// any other situation.
  static void encryptBlock(
    Uint8List data,
    int startIndex,
    List<int> p,
    List<List<int>> s,
  ) =>
      BlowfishCBCConverter._transformBlockCommon(
        data: data,
        startIndex: startIndex,
        p: p,
        s: s,
        loopStartAt: 0,
        looopStopBefore: 16,
        loopStep: 1,
      );
}

class BlowfishCBCDecoder extends BlowfishCBCConverter {
  BlowfishCBCDecoder(List<int> p, List<List<int>> s, Uint8List iv) : super(p, s, iv);

  @override
  Uint8List convert(List<int> input) {
    if (input.length % BlowfishCBC.blockSize != 0) {
      throw FormatException("Input data length must be multiple of block size");
    }

    Uint8List decrypted = Uint8List(input.length);
    Uint8List previousBlock = Uint8List.fromList(iv);
    Uint8List currentBlock = Uint8List(BlowfishCBC.blockSize);

    for (int i = 0; i < input.length; i += BlowfishCBC.blockSize) {
      currentBlock.setRange(0, BlowfishCBC.blockSize, input.sublist(i, i + BlowfishCBC.blockSize));
      _decryptBlock(currentBlock, 0, p, s);

      // XOR with previous block
      for (int j = 0; j < BlowfishCBC.blockSize; j++) {
        decrypted[i + j] = currentBlock[j] ^ previousBlock[j];
      }
      previousBlock.setRange(0, BlowfishCBC.blockSize, input.sublist(i, i + BlowfishCBC.blockSize));
    }

    return decrypted;
  }
  
  @override
  void _transformBlock(
    Uint8List data,
    int startIndex,
    List<int> p,
    List<List<int>> s,
  ) =>
      _decryptBlock(data, startIndex, p, s);

  /// Decrypts an 8-byte block of data in an existing list of [data], starting
  /// at [startIndex].
  static void _decryptBlock(
    Uint8List data,
    int startIndex,
    List<int> p,
    List<List<int>> s,
  ) =>
      BlowfishCBCConverter._transformBlockCommon(
        data: data,
        startIndex: startIndex,
        p: p,
        s: s,
        loopStartAt: 17,
        looopStopBefore: 1,
        loopStep: -1,
      );
}
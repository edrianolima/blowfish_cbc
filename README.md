# Blowfish CBC for Flutter/Dart

<p align="center">
<a href="https://pub.dev/packages/blowfish_cbc"><img src="https://img.shields.io/pub/v/blowfish_cbc" alt="pub: blowfish_cbc"></a>
<a href="https://www.gnu.org/licenses/lgpl-3.0.html"><img src="https://img.shields.io/badge/license-LGPL%20v3.0-green.svg" alt="License: LGPL v3.0"></a>
<a href="https://pub.dev/packages/lint"><img src="https://img.shields.io/badge/style-lint-4BC0F5.svg" alt="style: lint"></a>
</p>

A pure Dart [Codec](https://api.dart.dev/stable/2.10.4/dart-convert/Codec-class.html)
implementation for the [Blowfish CBC](https://www.schneier.com/academic/blowfish/)
encryption algorithm.

## Usage
The `BlowfishCBC` class fully implements [Codec](https://api.dart.dev/stable/2.10.4/dart-convert/Codec-class.html).

The following simple usage is adapted from the included example project:
```dart
const key = "Test@12345";
const message = 'Test@123';

final encrypted = BlowfishCBCUtil.encrypt(message, key);
final decrypted = BlowfishCBCUtil.decrypt(encrypted, key);

print('Encrypting "$message" with blowfish CBC base64.');
print('Encrypted: "$encrypted"');
print('Decrypting blowfish CBC base64 "$encrypted".');
print('Decrypted: "$decrypted"');
```

## License
This project is licensed under the GNU Lesser General Public License v3.0 - see the [LICENSE](LICENSE) and [`LICENCE.LESSER`](LICENSE.LESSER) file for details.

Essentially, if this package is modified in your project, the modified package
sources must be released.

## Inspiration
The algorithm implementation was ported over from the
[hacker1024 BlowfishECB implementation](https://github.com/hacker1024/blowfish_ecb.dart/tree/master).

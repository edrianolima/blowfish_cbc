import 'dart:developer';

import 'package:blowfish_cbc/blowfish_cbc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  /* Sample using BlowfishCBCUtil 
  const key = "Test@12345";
  const message = 'Test@123';

  final encrypted = BlowfishCBCUtil.encrypt(message, key);
  final decrypted = BlowfishCBCUtil.decrypt(encrypted, key);

  print('Encrypting "$message" with blowfish CBC base64.');
  print('Encrypted: "$encrypted"');
  print('Decrypting blowfish CBC base64 "$encrypted".');
  print('Decrypted: "$decrypted"');
  */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = "Blowfish CBC Cryptography";
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
          backgroundColor: Colors.blueGrey,
        ),
        body: const CryptoPage(),
      ),
    );
  }
}

class CryptoPage extends StatefulWidget {
  const CryptoPage({super.key});

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  final TextEditingController _keyController = TextEditingController(text: "Test@12345");
  final TextEditingController _messageController = TextEditingController();
  String _output = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Enter Key and Message',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _keyController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Key',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Message',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _encrypt(),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                  ),
                  child: const Text(
                    'Encrypt',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _decrypt(),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, 
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                  ),
                  child: const Text(
                    'Decrypt',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_output.isNotEmpty) ...[
            const Text(
              'Output:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SelectableText(_output, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final result = _output.replaceAll("Encrypted: ", "").replaceAll("Decrypted: ", "");
                Clipboard.setData(ClipboardData(text: result));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Output copied to clipboard!')),
                );
              },
              child: const Text('Copy to Clipboard'),
              style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
            ),
          ],
          _isLoading ? const CircularProgressIndicator() : Container(),
        ],
      ),
    );
  }

  void _encrypt() async {
    if (!_validateKey()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final key = _keyController.text;
      final message = _messageController.text;
      final encrypted = BlowfishCBCUtil.encrypt(message, key);
      setState(() {
        _output = 'Encrypted: $encrypted';
      });
    } catch (e) {
      _handleError(e as Exception);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _decrypt() async {
    if (!_validateKey()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final key = _keyController.text;
      final encryptedMessage = _messageController.text;
      final decrypted = BlowfishCBCUtil.decrypt(encryptedMessage, key);
      setState(() {
        _output = 'Decrypted: $decrypted';
      });
    } catch (e) {
      _handleError(e as Exception);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateKey() {
    if (_keyController.text.isEmpty) {
      _handleError(Exception('Key is required and cannot be empty.'));
      return false;
    }
    return true;
  }

  void _handleError(Exception e) {
    log("Error", error: e.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text("An error occurred: $e"),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                setState(() {
                  _output = '';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

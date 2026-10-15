import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class PasswordHash {
  const PasswordHash({required this.salt, required this.hash});

  final String salt;
  final String hash;
}

Future<PasswordHash> hashPassword(String password, {String? salt}) async {
  final random = Random.secure();
  final actualSalt =
      salt ?? base64.encode(List.generate(16, (_) => random.nextInt(256)));
  final hash = await Isolate.run(() => _derive(password, actualSalt));
  return PasswordHash(salt: actualSalt, hash: hash);
}

String _derive(String password, String salt) {
  const iterations = 120000;
  final hmac = Hmac(sha256, utf8.encode(password));
  final saltBytes = base64.decode(salt);
  final firstBlock = Uint8List(saltBytes.length + 4)
    ..setRange(0, saltBytes.length, saltBytes);
  ByteData.sublistView(firstBlock).setUint32(saltBytes.length, 1, Endian.big);
  var current = hmac.convert(firstBlock).bytes;
  final result = Uint8List.fromList(current);
  for (var i = 1; i < iterations; i++) {
    current = hmac.convert(current).bytes;
    for (var j = 0; j < result.length; j++) {
      result[j] ^= current[j];
    }
  }
  return base64.encode(result);
}

bool passwordHashesMatch(String first, String second) {
  if (first.length != second.length) return false;
  var difference = 0;
  for (var i = 0; i < first.length; i++) {
    difference |= first.codeUnitAt(i) ^ second.codeUnitAt(i);
  }
  return difference == 0;
}

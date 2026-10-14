import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<(DatabaseFactory, String)> databaseLocation() async {
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return (databaseFactoryFfi, path.join(directory.path, 'galaxy_rewards.db'));
  }
  final factory = mobile.databaseFactorySqflitePlugin;
  return (
    factory,
    path.join(await factory.getDatabasesPath(), 'galaxy_rewards.db'),
  );
}

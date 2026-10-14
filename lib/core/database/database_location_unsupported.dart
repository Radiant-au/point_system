import 'package:sqflite/sqflite.dart';

Future<(DatabaseFactory, String)> databaseLocation() async =>
    throw UnsupportedError(
      'SQLite storage supports Android, iOS, macOS, Linux, and Windows.',
    );

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'lib/data/database/app_database.dart';
import 'lib/core/utils/seed_textbausteine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(appDir.path, 'jobtracker.sqlite');
  print(dbPath);
  final db = AppDatabase();
  await seedTextbausteine(db);
  print('Done!');
  exit(0);
}

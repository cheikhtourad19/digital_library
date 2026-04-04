import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'database_config.dart';

class DatabaseService {

  static final DatabaseService instance = DatabaseService._internal();

  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {

    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {

    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      DatabaseConfig.databaseName,
    );

    return await openDatabase(
      path,
      version: DatabaseConfig.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    // tables will be created later

  }

  Future<void> _onUpgrade(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {

    // migrations will go here later

  }

}
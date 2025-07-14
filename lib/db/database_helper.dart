import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'htmlWebview.db');

    return await openDatabase(
      path,
      version: 1, // 🔼 Set version to 2
      onCreate: (Database db, int version) async {
        // 👇 Create only appUrl table initially
        await db.execute('''
          CREATE TABLE appUrl (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            url TEXT,
            icon TEXT
          )
        ''');

            await db.execute('''
            CREATE TABLE setting (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              value TEXT
            )
          ''');
      },

      // // 👇 This will be called when upgrading from version 1 to 2
      // onUpgrade: (Database db, int oldVersion, int newVersion) async {
      //   if (oldVersion < 2) {
      //     await db.execute('''
      //       CREATE TABLE setting (
      //         id INTEGER PRIMARY KEY AUTOINCREMENT,
      //         name TEXT,
      //         value TEXT
      //       )
      //     ''');
      //     print("✅ 'setting' table created during upgrade to v2");
      //   }
      // },
    );
  }

  // ---------------------- appUrl CRUD ----------------------

  Future<int> insertNote(String title, String url, String icon) async {
    final dbClient = await db;
    return await dbClient.insert('appUrl', {
      'title': title,
      'url': url,
      'icon': icon,
    });
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final dbClient = await db;
    return await dbClient.query('appUrl');
  }

  

  Future<int> deleteNote(int id) async {
    final dbClient = await db;
    return await dbClient.delete('appUrl', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------- setting CRUD ----------------------

  Future<int> insertSetting(String name, String value) async {
    final dbClient = await db;
    return await dbClient.insert('setting', {
      'name': name,
      'value': value,
    });
  }

  Future<List<Map<String, dynamic>>> getSetting() async {
    final dbClient = await db;
    return await dbClient.query('setting');
  }

  Future<int> deleteSetting(int id) async {
    final dbClient = await db;
    return await dbClient.delete('setting', where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getSettingValue(String name) async {
  final dbClient = await db;
  final result = await dbClient.query('setting', where: 'name = ?', whereArgs: [name]);

  if (result.isNotEmpty) {
    return result.first['value'] as String;
  }
  return null;
}


  // Optional: delete whole DB (only for dev)
  Future<void> deleteDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'htmlWebview.db');
    await deleteDatabase(path);
    print("❌ Database deleted");
  }
}

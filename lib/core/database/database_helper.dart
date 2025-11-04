import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const String _dbName = 'app_database.db';
  static const String tableUser = 'users';
  static const String tableFavorites = 'favorites';
  static const String tableCart = 'cart';
  static const String tableOrders = 'orders';
  static const String tableOrderItems = 'order_items';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUser (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableFavorites (
        mealId TEXT PRIMARY KEY
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCart (
        mealId TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        thumbnail TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrders (
        id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrderItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId TEXT NOT NULL,
        mealId TEXT NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (orderId) REFERENCES $tableOrders (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $tableCart (
          mealId TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          thumbnail TEXT NOT NULL,
          price REAL NOT NULL,
          category TEXT NOT NULL,
          quantity INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE $tableOrders (
          id TEXT PRIMARY KEY,
          timestamp INTEGER NOT NULL,
          total REAL NOT NULL,
          status TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE $tableOrderItems (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          orderId TEXT NOT NULL,
          mealId TEXT NOT NULL,
          name TEXT NOT NULL,
          price REAL NOT NULL,
          quantity INTEGER NOT NULL,
          FOREIGN KEY (orderId) REFERENCES $tableOrders (id)
        )
      ''');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
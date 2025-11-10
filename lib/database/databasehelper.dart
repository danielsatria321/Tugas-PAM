import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password_hash TEXT,
        name TEXT,
        xp INTEGER DEFAULT 0,
        subscription_status TEXT DEFAULT 'free',
        score_history TEXT DEFAULT '[]'
      )
    ''');
  }

  // === PASSWORD HASHING ===
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // === REGISTER USER ===
  Future<int> registerUser(String username, String password) async {
    final db = await database;
    final hashed = hashPassword(password);

    return await db.insert('users', {
      'username': username,
      'password_hash': hashed,
      'name': username,
      'xp': 0,
      'subscription_status': 'free',
      'score_history': jsonEncode([]),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // === LOGIN USER ===
  Future<Map<String, dynamic>?> loginUser(
    String username,
    String password,
  ) async {
    final db = await database;
    final hashed = hashPassword(password);

    final res = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, hashed],
    );

    return res.isNotEmpty ? res.first : null;
  }

  // === GET USER BY ID ===
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  // === GET USER BY USERNAME ===
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // === UPDATE XP ===
  Future<void> updateXP(int userId, int newXP) async {
    final db = await database;
    await db.update(
      'users',
      {'xp': newXP},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // === UPDATE SUBSCRIPTION STATUS ===
  Future<void> updateSubscription(int userId, String status) async {
    final db = await database;

    // Gunakan transaction untuk menghindari lock
    await db.transaction((txn) async {
      await txn.update(
        'users',
        {'subscription_status': status},
        where: 'id = ?',
        whereArgs: [userId],
      );
    });

    print('✅ Subscription updated: user $userId -> $status');
  }

  // === ADD SCORE TO HISTORY ===
  Future<void> addScoreToHistory(int userId, int newScore) async {
    final db = await database;

    final user = await getUserById(userId);
    if (user != null) {
      List<dynamic> scoreHistory = jsonDecode(user['score_history'] ?? '[]');
      scoreHistory.add(newScore);

      await db.update(
        'users',
        {'score_history': jsonEncode(scoreHistory)},
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
  }

  // === GET USER SCORES ===
  Future<List<Map<String, dynamic>>> getUserScores(int userId) async {
    final user = await getUserById(userId);
    if (user != null) {
      final scoreHistory = jsonDecode(user['score_history'] ?? '[]') as List;
      return scoreHistory.asMap().entries.map((entry) {
        return {'quiz_number': entry.key + 1, 'score': entry.value};
      }).toList();
    }
    return [];
  }

  // === GET ALL USERS ===
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // === DELETE USER ===
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // === SIMPLE DEBUG METHOD ===
  Future<void> printAllUsers() async {
    final users = await getAllUsers();
    print('=== DATABASE USERS ===');
    for (var user in users) {
      print(
        'ID: ${user['id']}, Username: ${user['username']}, Status: ${user['subscription_status']}',
      );
    }
    print('=====================');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_application_1/domain/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<Note> create(Note note) async {
    final db = await database;
    final id = await db.insert('notes', note.toMap());
    return note..id = id;
  }

  Future<List<Note>> readAllNotes() async {
    final db = await database;
    final result = await db.query('notes', orderBy: 'date DESC');
    return result.map((json) => Note(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
    )).toList();
  }

  Future<int> update(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}

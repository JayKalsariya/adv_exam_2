import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contacts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertContact(Map<String, dynamic> contact) async {
    final db = await database;
    await db.insert('contacts', contact);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await database;
    return await db.query('contacts');
  }

  // Add this function in DatabaseHelper
  Future<void> backupContact(Map<String, dynamic> contact) async {
    final CollectionReference contactsCollection =
        FirebaseFirestore.instance.collection('backedUpContacts');
    await contactsCollection.add(contact);
  }

  Future<List<Map<String, dynamic>>> getBackedUpContacts() async {
    final CollectionReference contactsCollection =
        FirebaseFirestore.instance.collection('backedUpContacts');

    QuerySnapshot querySnapshot = await contactsCollection.get();
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // Add this method in database_helper.dart
  Future<void> deleteBackedUpContact(String id) async {
    final CollectionReference contactsCollection =
        FirebaseFirestore.instance.collection('backedUpContacts');
    await contactsCollection.doc(id).delete();
  }
}

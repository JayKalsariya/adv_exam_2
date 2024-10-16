import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  Future<void> deleteContact(int id) async {
    final Database db = await database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> backupContact(Map<String, dynamic> contact) async {
    final CollectionReference contactsCollection =
        FirebaseFirestore.instance.collection('backedUpContacts');

    // Check if the contact already exists in Firestore by phone number
    final querySnapshot = await contactsCollection
        .where('phone', isEqualTo: contact['phone'])
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Contact doesn't exist, so we proceed to back it up
      await contactsCollection.add(contact);

      Fluttertoast.showToast(
        msg: 'Contact backed up!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.teal,
        textColor: Colors.white,
      );
    } else {
      // Contact already exists, so we show a different toast message
      Fluttertoast.showToast(
        msg: 'Contact is already backed up.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getBackedUpContacts() async {
    final CollectionReference contactsCollection =
        FirebaseFirestore.instance.collection('backedUpContacts');

    QuerySnapshot querySnapshot = await contactsCollection.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Ensure phone is treated as a string
      return {
        'id': doc.id,
        'name': data['name'] as String, // Assuming name is always a string
        'phone': data['phone'].toString(), // Convert phone to string
      };
    }).toList();
  }

  Future<void> deleteBackedUpContact(String id) async {
    final CollectionReference contactsCollection =
        FirebaseFirestore.instance.collection('backedUpContacts');
    await contactsCollection.doc(id).delete();
  }

  Future<Map<String, dynamic>?> getContactByPhone(String phone) async {
    final Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'contacts',
      where: 'phone = ?',
      whereArgs: [phone],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }
}

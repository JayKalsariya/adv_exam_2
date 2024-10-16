import 'package:adv_exam_2/helper/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackedUpContactsPage extends StatefulWidget {
  const BackedUpContactsPage({super.key});

  @override
  _BackedUpContactsPageState createState() => _BackedUpContactsPageState();
}

class _BackedUpContactsPageState extends State<BackedUpContactsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _backedUpContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchBackedUpContacts();
  }

  Future<void> _fetchBackedUpContacts() async {
    final contacts = await _dbHelper.getBackedUpContacts();
    setState(() {
      _backedUpContacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Backed Up Contacts',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal, // Different color for AppBar
      ),
      body: _backedUpContacts.isEmpty
          ? const Center(
              child: Text(
                'No backed-up contacts.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _backedUpContacts.length,
              itemBuilder: (context, index) {
                final contact = _backedUpContacts[index];
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      contact['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      contact['phone'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _dbHelper.deleteBackedUpContact(contact['id']);
                        _fetchBackedUpContacts();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

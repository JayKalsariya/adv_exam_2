import 'package:adv_exam_2/helper/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BackedUpContactsPage extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Backed Up Contacts')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getBackedUpContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No backed-up contacts.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final contact = snapshot.data![index];
              return ListTile(
                title: Text(contact['name']),
                subtitle: Text(contact['phone']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await _dbHelper.deleteBackedUpContact(contact['id']);
                    // Refresh the contact list
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BackedUpContactsPage(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getBackedUpContacts() async {
    final CollectionReference contactsCollection =
        FirebaseFirestore.instance.collection('backedUpContacts');

    QuerySnapshot querySnapshot = await contactsCollection.get();
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }
}

import 'package:adv_exam_2/helper/database_helper.dart';
import 'package:adv_exam_2/layouts/backupcontact/backup_contact_page.dart';
import 'package:adv_exam_2/layouts/homepage/component/build_contact_card.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    final contacts = await _dbHelper.getContacts(); // Fetch updated contacts
    setState(() {
      _contacts = contacts; // Update the state to reflect changes
    });
  }

  void _showAddContactDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.teal[50],
          title: const Text(
            'Add New Contact',
            style: TextStyle(color: Colors.teal),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                textCapitalization: TextCapitalization.words,
                cursorColor: Colors.teal,
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                cursorColor: Colors.teal,
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Phone',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.teal),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final String name = nameController.text;
                final String phone = phoneController.text;

                // Check for duplicate contact in the local database
                final existingContact =
                    await _dbHelper.getContactByPhone(phone);
                if (existingContact == null) {
                  // If no duplicate is found, add the new contact
                  Map<String, dynamic> newContact = {
                    'name': name,
                    'phone': phone,
                  };
                  await _dbHelper.insertContact(newContact);
                  Navigator.pop(context);
                  fetchContacts(); // Refresh contact list

                  Fluttertoast.showToast(
                    msg: 'Contact saved!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.teal,
                    textColor: Colors.white,
                  );
                } else {
                  // Show message if contact already exists
                  Fluttertoast.showToast(
                    msg: 'Contact already exists.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.orange,
                    textColor: Colors.white,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.backup, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BackedUpContactsPage()),
              );
            },
          ),
        ],
      ),
      body: _contacts.isEmpty
          ? const Center(child: Text('No any contacts'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                return buildContactCard(context, _contacts[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: Colors.teal,
        tooltip: 'Add Contact',
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

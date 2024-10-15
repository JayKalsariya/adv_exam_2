import 'package:adv_exam_2/helper/database_helper.dart';
import 'package:adv_exam_2/layouts/backupcontact/backup_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _fetchContacts();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.phone,
      Permission.sms,
      Permission.contacts,
    ].request();
  }

  Future<void> _fetchContacts() async {
    final contacts = await _dbHelper.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  void _showAddContactDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(hintText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final String name = nameController.text;
                final String phone = phoneController.text;

                Map<String, dynamic> newContact = {
                  'name': name,
                  'phone': phone
                };

                await _dbHelper.insertContact(newContact);
                Navigator.pop(context);
                _fetchContacts();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Request permission before making a call
    var status = await Permission.phone.request();
    if (status.isGranted) {
      final Uri callUri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $callUri');
      }
    } else {
      print('Phone permission denied');
    }
  }

  Future<void> _sendSms(String phone) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      Logger().i('Sending SMS to $phone');
    } else {
      print('Could not launch $smsUri');
    }
  }

  Future<void> _backupContact(Map<String, dynamic> contact) async {
    final CollectionReference contactsCollection =
        FirebaseFirestore.instance.collection('backedUpContacts');
    await contactsCollection.add(contact);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact backed up!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.backup),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BackedUpContactsPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_contacts[index]['name']),
            subtitle: Text(_contacts[index]['phone']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () => _makePhoneCall("+919265206725"),
                ),
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () => _sendSms(_contacts[index]['phone']),
                ),
                IconButton(
                  icon: Icon(Icons.cloud_upload),
                  onPressed: () => _backupContact(_contacts[index]),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddContactDialog,
      ),
    );
  }
}

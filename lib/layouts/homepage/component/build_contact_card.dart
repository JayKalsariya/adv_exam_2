import 'package:adv_exam_2/helper/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _callContact(String phone) async {
  final Uri callUri = Uri(scheme: 'tel', path: phone);
  if (await canLaunchUrl(callUri)) {
    await launchUrl(callUri);
  } else {
    print('Could not launch $callUri');
  }
}

Future<void> _sendSms(String phone) async {
  final Uri smsUri = Uri(scheme: 'sms', path: phone);
  if (await canLaunchUrl(smsUri)) {
    await launchUrl(smsUri);
  } else {
    print('Could not launch $smsUri');
  }
}

// Widget buildContactCard(Map<String, dynamic> contact) {
//   return Card(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     elevation: 4,
//     margin: const EdgeInsets.symmetric(vertical: 6),
//     child: ListTile(
//       contentPadding: const EdgeInsets.all(12),
//       leading: CircleAvatar(
//         radius: 24,
//         backgroundColor: Colors.blueGrey[200],
//         child: const Icon(Icons.person, size: 24, color: Colors.white),
//       ),
//       title: Text(
//         contact['name'],
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//       ),
//       subtitle: Text(
//         contact['phone'],
//         style: TextStyle(color: Colors.grey[600], fontSize: 14),
//       ),
//       trailing: Wrap(
//         spacing: 8,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.call, color: Colors.green),
//             onPressed: () => _callContact(contact['phone']),
//           ),
//           IconButton(
//             icon: const Icon(Icons.message, color: Colors.blue),
//             onPressed: () => _sendSms(contact['phone']),
//           ),
//           IconButton(
//             icon: const Icon(Icons.cloud_upload, color: Colors.orange),
//             onPressed: () => DatabaseHelper().backupContact(contact),
//           ),
//         ],
//       ),
//     ),
//   );
// }

void _showDeleteDialog(BuildContext context, Map<String, dynamic> contact) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact['name']}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper().deleteContact(contact['id']);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

Widget buildContactCard(
  BuildContext context,
  Map<String, dynamic> contact,
) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: GestureDetector(
      onLongPress: () {
        _showDeleteDialog(context, contact);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blueGrey[200],
          child: const Icon(Icons.person, size: 24, color: Colors.white),
        ),
        title: Text(
          contact['name'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          contact['phone'],
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _callContact(contact['phone']),
            ),
            IconButton(
              icon: const Icon(Icons.message, color: Colors.blue),
              onPressed: () => _sendSms(contact['phone']),
            ),
            IconButton(
              icon: const Icon(Icons.cloud_upload, color: Colors.orange),
              onPressed: () => DatabaseHelper().backupContact(contact),
            ),
          ],
        ),
      ),
    ),
  );
}

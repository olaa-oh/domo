// shows the notifications the artisan receives and sends
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notifications.txt');

    if (file.existsSync()) {
      final contents = await file.readAsString();
      setState(() {
        notifications = contents.split('\n').where((line) => line.isNotEmpty).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notifications[index]),
          );
        },
      ),
    );
  }
}

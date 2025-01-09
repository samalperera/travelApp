import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/inbox_provider.dart';

class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    if (_userId == null) return;

    try {
      await Provider.of<InboxProvider>(context, listen: false)
          .fetchMessages(_userId!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inboxProvider = Provider.of<InboxProvider>(context);
    final messages = inboxProvider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
      ),
      body: messages.isEmpty
          ? Center(
        child: Text(
          'No messages in your inbox.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: messages.length,
        itemBuilder: (ctx, index) {
          final message = messages[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                message['title'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(message['body']),
              trailing: Text(
                _formatTimestamp(message['timestamp']),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Format Firestore timestamp into a readable date
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = (timestamp as Timestamp).toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

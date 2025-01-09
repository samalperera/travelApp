import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class InboxProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get messages => [..._messages];

  /// Fetch messages for the current user
  Future<void> fetchMessages(String userId) async {
    try {
      _messages = await _firebaseService.fetchInboxMessages(userId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }
}

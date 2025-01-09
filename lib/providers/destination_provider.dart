import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/firebase_service.dart';

class DestinationProvider with ChangeNotifier {
  List<Destination> _destinations = [];
  Destination? _selectedDestination;

  List<Destination> get destinations => [..._destinations];

  Destination? get selectedDestination => _selectedDestination;

  Future<void> fetchDestinations() async {
    final firebaseService = FirebaseService();
    final fetchedDestinations = await firebaseService.getDestinations();
    _destinations = fetchedDestinations.map((doc) => Destination.fromFirestore(doc.data()!, doc.id)).toList();
    notifyListeners();
  }

  Future<void> getDestinationById(String id) async {
    try {
      final firebaseService = FirebaseService();
      final doc = await firebaseService.getDestinationById(id);

      if (doc.exists) {
        _selectedDestination = Destination.fromFirestore(doc.data()!, doc.id);
        notifyListeners(); // Notify listeners that the selected destination has changed
      } else {
        _selectedDestination = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching destination by ID: $e');
    }
  }
}

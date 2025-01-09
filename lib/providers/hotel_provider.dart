import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/firebase_service.dart';

class HotelProvider with ChangeNotifier {
  List<Hotel> _hotels = [];

  List<Hotel> get hotels => [..._hotels];

  Future<void> fetchHotelsByDestination(String destinationId) async {
    final firebaseService = FirebaseService();
    final fetchedHotels = await firebaseService.getHotelsByDestinationId(destinationId);
    _hotels = fetchedHotels.map((doc) {
      return Hotel.fromFirestore(doc.data(), doc.id);
    }).toList();
    notifyListeners();// Notify UI of changes
  }
}
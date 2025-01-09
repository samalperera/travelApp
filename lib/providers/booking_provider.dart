import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _bookings = [];

  List<Map<String, dynamic>> get bookings => [..._bookings];

  /// Fetch bookings for a specific user
  Future<void> fetchUserBookings(String userId) async {
    try {
      final fetchedBookings = await _firebaseService.fetchBookingsByUser(userId);

      _bookings = await Future.wait(fetchedBookings.map((booking) async {
        final hotelData = await _firebaseService.getHotelById(booking['hotelId']);
        final destinationData =
        await _firebaseService.getDestinationById(hotelData['destinationId']);
        return {
          'id': booking['id'],
          'hotelName': hotelData['hotelName'],
          'destinationName': destinationData['name'],
          'checkInDate': booking['checkInDate'],
          'checkOutDate': booking['checkOutDate'],
        };
      }).toList());

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }


  /// Add a booking
  Future<void> addBooking({
    required String userId,
    required String hotelId,
    required String hotelName,
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) async {
    try {
      await _firebaseService.bookHotel(
        hotelId: hotelId,
        userId: userId,
        userName: hotelName, // Pass userName dynamically
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      // Add the new booking to local state
      _bookings.add({
        'id': DateTime.now().toString(), // Temporary ID until Firestore returns real ID
        'hotelName': hotelName,
        'checkInDate': checkInDate,
        'checkOutDate': checkOutDate,
      });

      notifyListeners();
    } catch (e) {
      print('Error adding booking: $e');
    }
  }

  /// Update an existing booking
  Future<void> updateBooking({
    required String bookingId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) async {
    try {
      await _firebaseService.updateBooking(
        bookingId: bookingId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      // Update local state
      final bookingIndex = _bookings.indexWhere((booking) => booking['id'] == bookingId);
      if (bookingIndex >= 0) {
        _bookings[bookingIndex]['checkInDate'] = checkInDate;
        _bookings[bookingIndex]['checkOutDate'] = checkOutDate;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating booking: $e');
    }
  }

  /// Remove a booking
  Future<void> removeBooking(String bookingId) async {
    try {
      await _firebaseService.deleteBooking(bookingId);

      // Remove from local state
      _bookings.removeWhere((booking) => booking['id'] == bookingId);
      notifyListeners();
    } catch (e) {
      print('Error removing booking: $e');
    }
  }
}

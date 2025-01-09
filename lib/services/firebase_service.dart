import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // Collection references with converters for destinations and hotels
  final CollectionReference<Map<String, dynamic>> _destinationCollection =
  FirebaseFirestore.instance.collection('destinations').withConverter<Map<String, dynamic>>(
    fromFirestore: (snapshot, _) => snapshot.data()!,
    toFirestore: (data, _) => data,
  );

  final CollectionReference<Map<String, dynamic>> _hotelCollection =
  FirebaseFirestore.instance.collection('hotels').withConverter<Map<String, dynamic>>(
    fromFirestore: (snapshot, _) => snapshot.data()!,
    toFirestore: (data, _) => data,
  );

  final CollectionReference<Map<String, dynamic>> _bookingsCollection =
  FirebaseFirestore.instance.collection('bookings');

  final CollectionReference<Map<String, dynamic>> _usersCollection =
  FirebaseFirestore.instance.collection('users');

  /// Fetch all destinations
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getDestinations() async {
    try {
      final snapshot = await _destinationCollection.get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Failed to fetch destinations: $e');
    }
  }

  /// Fetch a destination by its ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDestinationById(String id) async {
    try {
      return await _destinationCollection.doc(id).get();
    } catch (e) {
      throw Exception('Failed to fetch destination: $e');
    }
  }

  /// Fetch hotels by destination ID
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getHotelsByDestinationId(String destinationId) async {
    try {
      final snapshot = await _hotelCollection.where('destinationId', isEqualTo: destinationId).get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Failed to fetch hotels: $e');
    }
  }

  /// Book a hotel
  Future<void> bookHotel({
    required String hotelId,
    required String userId,
    required String userName,
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) async {
    try {
      await _bookingsCollection.add({
        'userId': userId,
        'hotelId': hotelId,
        'userName': userName,
        'checkInDate': Timestamp.fromDate(checkInDate),
        'checkOutDate': Timestamp.fromDate(checkOutDate),
        'bookingTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to book hotel: $e');
    }
  }

  /// Add hotel to user's wishlist
  Future<void> addToWishlist(String userId, String hotelId) async {
    try {
      await _usersCollection.doc(userId).collection('wishlist').doc(hotelId).set({});
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  /// Fetch wishlist for a user
  Future<List<String>> fetchWishlist(String userId) async {
    try {
      final snapshot = await _usersCollection.doc(userId).collection('wishlist').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to fetch wishlist: $e');
    }
  }

  /// Fetch bookings by user ID
  Future<List<Map<String, dynamic>>> fetchBookingsByUser(String userId) async {
    try {
      final snapshot = await _bookingsCollection.where('userId', isEqualTo: userId).get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  /// Update a booking by its ID
  Future<void> updateBooking({
    required String bookingId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'checkInDate': Timestamp.fromDate(checkInDate),
        'checkOutDate': Timestamp.fromDate(checkOutDate),
      });
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  /// Delete a booking by its ID
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }
  Future<Map<String, dynamic>> getHotelById(String hotelId) async {
    try {
      final snapshot = await _hotelCollection.doc(hotelId).get();
      return snapshot.data() ?? {};
    } catch (e) {
      throw Exception('Failed to fetch hotel: $e');
    }
  }
  final CollectionReference<Map<String, dynamic>> _inboxCollection =
  FirebaseFirestore.instance.collection('messageInbox');

  /// Fetch inbox messages for a user by userId
  Future<List<Map<String, dynamic>>> fetchInboxMessages(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('messageInbox')
          .where('userId', isEqualTo: userId)

          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch inbox messages: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/screens/edit_booking_screen.dart';
import '../providers/booking_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  void _fetchBookings() async {
    try {
      await Provider.of<BookingProvider>(context, listen: false)
          .fetchUserBookings(userId!);
      print('Bookings fetched successfully');
    } catch (e) {
      print('Error fetching bookings: $e');
    }
  }

  void _deleteBooking(BuildContext context, String bookingId) async {
    try {
      await Provider.of<BookingProvider>(context, listen: false)
          .removeBooking(bookingId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.bookings;

    return Scaffold(
      appBar: AppBar(title: Text('My Bookings')),
      body: bookings.isEmpty
          ? Center(child: Text('No bookings found'))
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (ctx, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Hotel : ${booking['hotelName']}"),
              subtitle: Text(
                'Check-In: ${formatMilliseconds(booking['checkInDate'])}\n'
                    'Check-Out: ${booking['checkOutDate']}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditBookingScreen(
                            bookingId: booking['id'], // Pass booking ID
                            hotelName: booking['hotelName'], // Pass hotel name
                            initialCheckInDate: booking['checkInDate'], // Pass check-in date
                            initialCheckOutDate: booking['checkOutDate'], // Pass check-out date
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      _deleteBooking(context, booking['id']);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String formatMilliseconds(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}

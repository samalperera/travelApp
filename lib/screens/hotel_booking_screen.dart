import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/booking_provider.dart';

class HotelBookingScreen extends StatefulWidget {
  final String hotelId;
  final String hotelName;

  const HotelBookingScreen({
    Key? key,
    required this.hotelId,
    required this.hotelName,
  }) : super(key: key);

  @override
  _HotelBookingScreenState createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = selectedDate;
        } else {
          _checkOutDate = selectedDate;
        }
      });
    }
  }

  Future<void> _confirmBooking(BuildContext context) async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both check-in and check-out dates')),
      );
      return;
    }

    if (_checkInDate!.isAfter(_checkOutDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-out date must be after check-in date')),
      );
      return;
    }

    // Get the BookingProvider
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    try {
      // Use the addBooking method
      await bookingProvider.addBooking(
        userId: userId!,
        hotelId: widget.hotelId,
        hotelName: widget.hotelName,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed for ${widget.hotelName}')),
      );

      // Navigate back or to a success screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.hotelName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Hotel Name: ${widget.hotelName}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(_checkInDate == null
                  ? 'Select Check-In Date'
                  : 'Check-In: ${dateFormat.format(_checkInDate!)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text(_checkOutDate == null
                  ? 'Select Check-Out Date'
                  : 'Check-Out: ${dateFormat.format(_checkOutDate!)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _confirmBooking(context),
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}

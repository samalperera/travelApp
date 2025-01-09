import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/booking_provider.dart';

class EditBookingScreen extends StatefulWidget {
  final String bookingId;
  final String hotelName;
  final DateTime initialCheckInDate;
  final DateTime initialCheckOutDate;

  const EditBookingScreen({
    Key? key,
    required this.bookingId,
    required this.hotelName,
    required this.initialCheckInDate,
    required this.initialCheckOutDate,
  }) : super(key: key);

  @override
  _EditBookingScreenState createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  @override
  void initState() {
    super.initState();
    _checkInDate = widget.initialCheckInDate;
    _checkOutDate = widget.initialCheckOutDate;
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate! : _checkOutDate!,
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

  Future<void> _updateBooking(BuildContext context) async {
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

    try {
      // Update the booking via BookingProvider
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.updateBooking(
        bookingId: widget.bookingId,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking updated successfully')),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(title: Text('Edit Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Booking Details',
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
              onPressed: () => _updateBooking(context),
              child: Text('Update Booking'),
            ),
          ],
        ),
      ),
    );
  }
}

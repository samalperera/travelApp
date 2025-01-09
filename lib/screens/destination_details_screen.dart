import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db_helper/database_handler.dart';
import '../providers/hotel_provider.dart';
import '../models/hotel.dart';
import 'hotel_booking_screen.dart';

class DestinationDetailsScreen extends StatefulWidget {
  final String destinationId;

  const DestinationDetailsScreen({Key? key, required this.destinationId}) : super(key: key);

  @override
  _DestinationDetailsScreenState createState() => _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  final DatabaseHandler _databaseHandler = DatabaseHandler(); // Initialize DatabaseHandler

  @override
  void initState() {
    super.initState();
    // Fetch hotels for the given destination ID
    Provider.of<HotelProvider>(context, listen: false)
        .fetchHotelsByDestination(widget.destinationId);
  }

  /// Toggle favorite status
  Future<void> _toggleFavorite(Hotel hotel) async {
    final List<Hotel> favorites = await _databaseHandler.getBookmarks();

    if (favorites.any((fav) => fav.id == hotel.id)) {
      // Remove from favorites if already added
      await _databaseHandler.deleteBookmark(hotel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${hotel.name} removed from favorites')),
      );
    } else {
      // Add to favorites
      await _databaseHandler.insertBookmark(hotel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${hotel.name} added to favorites')),
      );
    }

    // Update the UI
    setState(() {});
  }

  /// Check if a hotel is in favorites
  Future<bool> _isFavorite(Hotel hotel) async {
    final List<Hotel> favorites = await _databaseHandler.getBookmarks();
    return favorites.any((fav) => fav.id == hotel.id);
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);
    final hotels = hotelProvider.hotels;

    return Scaffold(
      appBar: AppBar(
        title: Text('Destination Details'),
      ),
      body: hotels.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: hotels.length,
        itemBuilder: (ctx, index) {
          final Hotel hotel = hotels[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Image.network(
                hotel.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              title: Text(hotel.name!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: \$${hotel.price}'),
                  Text('Stars: ${hotel.stars}'),
                ],
              ),
              trailing: FutureBuilder<bool>(
                future: _isFavorite(hotel),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Icon(Icons.favorite_border, color: Colors.grey);
                  }

                  final isFavorite = snapshot.data ?? false;

                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(hotel),
                  );
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HotelBookingScreen(
                      hotelId: hotel.id!,
                      hotelName: hotel.name!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

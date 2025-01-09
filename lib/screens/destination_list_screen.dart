import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/destination_provider.dart';
import '../components/custom_card.dart';
import 'destination_details_screen.dart';

class DestinationListScreen extends StatefulWidget {
  @override
  _DestinationListScreenState createState() => _DestinationListScreenState();
}

class _DestinationListScreenState extends State<DestinationListScreen> {
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
  }

  void _fetchDestinations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<DestinationProvider>(context, listen: false).fetchDestinations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load destinations')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinationProvider = Provider.of<DestinationProvider>(context);
    final destinations = destinationProvider.destinations;

    // Filter destinations based on the search query
    final filteredDestinations = _searchQuery.isEmpty
        ? destinations
        : destinations.where((destination) {
      return destination.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Destinations'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredDestinations.isEmpty
          ? Center(child: Text('No destinations found'))
          : ListView.builder(
        itemCount: filteredDestinations.length,
        itemBuilder: (ctx, index) {
          return CustomCard(
            title: filteredDestinations[index].name,
            subtitle: filteredDestinations[index].description,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DestinationDetailsScreen(
                    destinationId: filteredDestinations[index].id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

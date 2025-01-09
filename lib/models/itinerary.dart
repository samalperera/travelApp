class Itinerary {
  final String id;
  final String title;
  final List<String> activities;

  Itinerary({
    required this.id,
    required this.title,
    required this.activities,
  });

  factory Itinerary.fromFirestore(Map<String, dynamic> data, String id) {
    return Itinerary(
      id: id,
      title: data['title'],
      activities: List<String>.from(data['activities']),
    );
  }
}

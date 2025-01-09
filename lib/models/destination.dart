class Destination {
  final String id;
  final String name;
  final String description;
  final String location;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
  });

  factory Destination.fromFirestore(Map<String, dynamic> data, String id) {
    return Destination(
      id: id,
      name: data['name'],
      description: data['description'],
      location: data['location'],
    );
  }
}

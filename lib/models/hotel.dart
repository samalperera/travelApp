class Hotel {
  dynamic? id;
  String? name;
  String? imageUrl;
  String? price;
  String? stars;
  String? destinationId;

  Hotel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.stars,
    required this.destinationId,
  });

  Hotel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    price = json['price'];
    stars = json['stars'];
    destinationId = json['destinationId'];
  }

  // Factory constructor to map Firestore data
  factory Hotel.fromFirestore(Map<String, dynamic> data, String id) {
    return Hotel(
      id: id,
      name: data['hotelName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: data['price'] ?? '',
      stars: data['stars'] ?? '',
      destinationId: data['destinationId'] ?? '',
    );
  }
}

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travelapp/models/hotel.dart';

class DatabaseHandler {
  Future<Database> initialiseDatabase() async {
    String path = await getDatabasesPath();

    const String tableCreateQuery = '''
    CREATE TABLE hotels(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hotelId TEXT,
      name TEXT,
      imageUrl TEXT,
      price TEXT,
      stars TEXT,
      destinationId TEXT 
    )
  ''';

    return openDatabase(join(path, 'travel.db'),
        onCreate: (database, version) async {
      await database.execute(tableCreateQuery);

      print("###################################################.");
      print("table created.");
      print("###################################################.");
    }, version: 1);
  }

  Future<void> insertBookmark(Hotel hotel) async {
    final Database db = await initialiseDatabase();
    final Map<String, dynamic> dataToInsert = {
      'name': hotel.name,
      'imageUrl': hotel.imageUrl,
      'price': hotel.price,
      'stars': hotel.stars,
      'destinationId': hotel.destinationId,
    };

    await db.insert("hotels", dataToInsert);
  }

  Future<List<Hotel>> getBookmarks() async {
    final Database db = await initialiseDatabase();
    final result = await db.query("hotels");
    List<Hotel> articles = result.map((e) => Hotel.fromJson(e)).toList();

    return articles;
  }

  Future<void> deleteBookmark(Hotel hotel) async {
    final Database db = await initialiseDatabase();
    await db.delete(
      "hotels",
      where: "id = ?",
      whereArgs: [hotel.id],
    );
  }

  Future<void> insertBulkHotels(List<Hotel> hotels) async {
    await deleteAllHotels();
    final Database db = await initialiseDatabase();
    for (final hotel in hotels) {
      final Map<String, dynamic> dataToInsert = {
        'name': hotel.name,
        'imageUrl': hotel.imageUrl,
        'price': hotel.price,
        'stars': hotel.stars,
        'destinationId': hotel.destinationId,
      };

      await db.insert("hotels", dataToInsert);
    }
  }

  Future<void> deleteAllHotels() async {
    final Database db = await initialiseDatabase();
    await db.delete("hotels");
  }

  Future<List<Hotel>> getHotels() async {
    final Database db = await initialiseDatabase();
    final result = await db.query("hotels");
    List<Hotel> hotels = result.map((e) => Hotel.fromJson(e)).toList();

    return hotels;
  }
}

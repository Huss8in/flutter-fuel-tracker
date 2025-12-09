import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: 'https://fuel-tracker-61b88-default-rtdb.europe-west1.firebasedatabase.app'
  ).ref();

  DatabaseReference get fuelEntries => _database.child('fuel_entries');

  Future<void> saveFuelEntries(List<Map<String, dynamic>> entries) async {
    try {
      await fuelEntries.set(entries);
    } catch (e) {
      throw Exception('Failed to save fuel entries: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadFuelEntries() async {
    try {
      final snapshot = await fuelEntries.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        if (data is List) {
          return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (data is Map) {
          return [Map<String, dynamic>.from(data)];
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load fuel entries: $e');
    }
  }

  Future<void> addFuelEntry(Map<String, dynamic> entry) async {
    try {
      final entriesSnapshot = await fuelEntries.get();
      List<Map<String, dynamic>> entries = [];
      
      if (entriesSnapshot.exists && entriesSnapshot.value != null) {
        final data = entriesSnapshot.value;
        if (data is List) {
          entries = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (data is Map) {
          entries = [Map<String, dynamic>.from(data)];
        }
      }
      
      entries.add(entry);
      await fuelEntries.set(entries);
    } catch (e) {
      throw Exception('Failed to add fuel entry: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> watchFuelEntries() {
    return fuelEntries.onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value;
        if (data is List) {
          return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (data is Map) {
          return [Map<String, dynamic>.from(data)];
        }
      }
      return <Map<String, dynamic>>[];
    });
  }
}
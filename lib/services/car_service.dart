import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/car.dart';

class CarService {
  static final CarService _instance = CarService._internal();
  factory CarService() => _instance;
  CarService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get reference to user's cars collection
  CollectionReference _getUserCarsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('cars');
  }

  // Add a new car to the user's cars subcollection
  Future<String> addCar({
    required String make,
    required String model,
    required int year,
    required String fuelType,
    required String registrationNumber,
    required double currentMileage,
    String? imageUrl,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final car = Car(
        make: make,
        model: model,
        year: year,
        fuelType: fuelType,
        registrationNumber: registrationNumber,
        currentMileage: currentMileage,
        imageUrl: imageUrl,
      );

      final docRef = await _getUserCarsCollection(userId).add(car.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add car: $e');
    }
  }

  // Add a car with a specific ID
  Future<void> addCarWithId({
    required String carId,
    required String make,
    required String model,
    required int year,
    required String fuelType,
    required String registrationNumber,
    required double currentMileage,
    String? imageUrl,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final car = Car(
        id: carId,
        make: make,
        model: model,
        year: year,
        fuelType: fuelType,
        registrationNumber: registrationNumber,
        currentMileage: currentMileage,
        imageUrl: imageUrl,
      );

      await _getUserCarsCollection(userId).doc(carId).set(car.toMap());
    } catch (e) {
      throw Exception('Failed to add car with ID: $e');
    }
  }

  // Get a specific car by ID
  Future<Car?> getCar(String carId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _getUserCarsCollection(userId).doc(carId).get();
      if (doc.exists && doc.data() != null) {
        return Car.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get car: $e');
    }
  }

  // Get all cars for the current user
  Future<List<Car>> getAllCars() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _getUserCarsCollection(userId).get();
      return querySnapshot.docs
          .map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all cars: $e');
    }
  }

  // Update a car
  Future<void> updateCar({
    required String carId,
    String? make,
    String? model,
    int? year,
    String? fuelType,
    String? registrationNumber,
    double? currentMileage,
    String? imageUrl,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final Map<String, dynamic> updates = {};
      if (make != null) updates['make'] = make;
      if (model != null) updates['model'] = model;
      if (year != null) updates['year'] = year;
      if (fuelType != null) updates['fuelType'] = fuelType;
      if (registrationNumber != null) {
        updates['registrationNumber'] = registrationNumber;
      }
      if (currentMileage != null) updates['currentMileage'] = currentMileage;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;

      if (updates.isNotEmpty) {
        await _getUserCarsCollection(userId).doc(carId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update car: $e');
    }
  }

  // Update car mileage
  Future<void> updateCarMileage(String carId, double newMileage) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _getUserCarsCollection(
        userId,
      ).doc(carId).update({'currentMileage': newMileage});
    } catch (e) {
      throw Exception('Failed to update car mileage: $e');
    }
  }

  // Update car image
  Future<void> updateCarImage(String carId, String imageUrl) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _getUserCarsCollection(
        userId,
      ).doc(carId).update({'imageUrl': imageUrl});
    } catch (e) {
      throw Exception('Failed to update car image: $e');
    }
  }

  // Delete a car
  Future<void> deleteCar(String carId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _getUserCarsCollection(userId).doc(carId).delete();
    } catch (e) {
      throw Exception('Failed to delete car: $e');
    }
  }

  // Stream all cars for the current user
  Stream<List<Car>> streamAllCars() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _getUserCarsCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Stream a specific car
  Stream<Car?> streamCar(String carId) {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value(null);
    }

    return _getUserCarsCollection(userId).doc(carId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return Car.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // Get reference to fuel_logs subcollection for a specific car
  CollectionReference getFuelLogsCollection(String carId) {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _getUserCarsCollection(userId).doc(carId).collection('fuel_logs');
  }

  // Get reference to maintenance_logs subcollection for a specific car
  CollectionReference getMaintenanceLogsCollection(String carId) {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _getUserCarsCollection(
      userId,
    ).doc(carId).collection('maintenance_logs');
  }

  // Check if a car exists
  Future<bool> carExists(String carId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return false;
      }

      final doc = await _getUserCarsCollection(userId).doc(carId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get cars count for the current user
  Future<int> getCarsCount() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return 0;
      }

      final querySnapshot = await _getUserCarsCollection(userId).get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get cars count: $e');
    }
  }
}

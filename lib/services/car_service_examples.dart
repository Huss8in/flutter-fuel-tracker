import 'package:fuel_tracker/services/car_service.dart';

/// This file demonstrates how to use the CarService to manage cars in Firestore.
///
/// The CarService provides comprehensive CRUD operations for managing cars
/// in the users/{userId}/cars subcollection structure.

class CarServiceExamples {
  final CarService _carService = CarService();

  /// Example 1: Add a new car (auto-generated ID)
  Future<void> addNewCar() async {
    try {
      final carId = await _carService.addCar(
        make: 'Toyota',
        model: 'Corolla',
        year: 2020,
        fuelType: 'Petrol',
        registrationNumber: 'ABC-123',
        currentMileage: 50000.0,
        imageUrl: 'https://example.com/car-image.jpg', // Optional
      );

      print('Car added successfully with ID: $carId');
    } catch (e) {
      print('Error adding car: $e');
    }
  }

  /// Example 2: Add a car with a specific ID
  Future<void> addCarWithSpecificId() async {
    try {
      await _carService.addCarWithId(
        carId: 'my-custom-car-id',
        make: 'Ford',
        model: 'Mustang',
        year: 2021,
        fuelType: 'Petrol',
        registrationNumber: 'XYZ-789',
        currentMileage: 30000.0,
        imageUrl: null, // Optional field
      );

      print('Car added successfully with custom ID');
    } catch (e) {
      print('Error adding car with ID: $e');
    }
  }

  /// Example 3: Get a specific car by ID
  Future<void> getCarById(String carId) async {
    try {
      final car = await _carService.getCar(carId);

      if (car != null) {
        print('Car found: ${car.make} ${car.model}');
        print('Year: ${car.year}');
        print('Fuel Type: ${car.fuelType}');
        print('Registration: ${car.registrationNumber}');
        print('Current Mileage: ${car.currentMileage}');
      } else {
        print('Car not found');
      }
    } catch (e) {
      print('Error getting car: $e');
    }
  }

  /// Example 4: Get all cars for the current user
  Future<void> getAllUserCars() async {
    try {
      final cars = await _carService.getAllCars();

      print('Total cars: ${cars.length}');
      for (var car in cars) {
        print(
          '${car.year} ${car.make} ${car.model} - ${car.registrationNumber}',
        );
      }
    } catch (e) {
      print('Error getting all cars: $e');
    }
  }

  /// Example 5: Update a car's information
  Future<void> updateCarInfo(String carId) async {
    try {
      await _carService.updateCar(
        carId: carId,
        currentMileage: 55000.0, // Update only mileage
        // You can update any combination of fields
        // make: 'Honda',
        // model: 'Civic',
        // year: 2022,
        // fuelType: 'Hybrid',
        // registrationNumber: 'NEW-123',
        // imageUrl: 'https://example.com/new-image.jpg',
      );

      print('Car updated successfully');
    } catch (e) {
      print('Error updating car: $e');
    }
  }

  /// Example 6: Update only the car's mileage
  Future<void> updateMileage(String carId, double newMileage) async {
    try {
      await _carService.updateCarMileage(carId, newMileage);
      print('Mileage updated to: $newMileage');
    } catch (e) {
      print('Error updating mileage: $e');
    }
  }

  /// Example 7: Update only the car's image
  Future<void> updateCarPhoto(String carId, String imageUrl) async {
    try {
      await _carService.updateCarImage(carId, imageUrl);
      print('Car image updated');
    } catch (e) {
      print('Error updating car image: $e');
    }
  }

  /// Example 8: Delete a car
  Future<void> removeCar(String carId) async {
    try {
      await _carService.deleteCar(carId);
      print('Car deleted successfully');
    } catch (e) {
      print('Error deleting car: $e');
    }
  }

  /// Example 9: Stream all cars (real-time updates)
  void streamAllCars() {
    _carService.streamAllCars().listen(
      (cars) {
        print('Cars updated: ${cars.length} cars');
        for (var car in cars) {
          print('${car.make} ${car.model} - ${car.currentMileage} km');
        }
      },
      onError: (error) {
        print('Error streaming cars: $error');
      },
    );
  }

  /// Example 10: Stream a specific car (real-time updates)
  void streamSingleCar(String carId) {
    _carService
        .streamCar(carId)
        .listen(
          (car) {
            if (car != null) {
              print('Car updated: ${car.make} ${car.model}');
              print('Current mileage: ${car.currentMileage}');
            } else {
              print('Car not found or deleted');
            }
          },
          onError: (error) {
            print('Error streaming car: $error');
          },
        );
  }

  /// Example 11: Check if a car exists
  Future<void> checkCarExists(String carId) async {
    try {
      final exists = await _carService.carExists(carId);
      print('Car exists: $exists');
    } catch (e) {
      print('Error checking car existence: $e');
    }
  }

  /// Example 12: Get total number of cars
  Future<void> getTotalCars() async {
    try {
      final count = await _carService.getCarsCount();
      print('Total cars: $count');
    } catch (e) {
      print('Error getting cars count: $e');
    }
  }

  /// Example 13: Get references to subcollections
  void getSubcollectionReferences(String carId) {
    try {
      // Get reference to fuel_logs subcollection
      final fuelLogsRef = _carService.getFuelLogsCollection(carId);
      print('Fuel logs collection path: ${fuelLogsRef.path}');
      // Path will be: users/{userId}/cars/{carId}/fuel_logs

      // Get reference to maintenance_logs subcollection
      final maintenanceLogsRef = _carService.getMaintenanceLogsCollection(
        carId,
      );
      print('Maintenance logs collection path: ${maintenanceLogsRef.path}');
      // Path will be: users/{userId}/cars/{carId}/maintenance_logs

      // You can use these references to add/query fuel logs and maintenance logs
      // Example: await fuelLogsRef.add({...});
    } catch (e) {
      print('Error getting subcollection references: $e');
    }
  }

  /// Example 14: Complete workflow - Add car and add fuel log
  Future<void> completeWorkflow() async {
    try {
      // Step 1: Add a new car
      final carId = await _carService.addCar(
        make: 'Tesla',
        model: 'Model 3',
        year: 2023,
        fuelType: 'EV',
        registrationNumber: 'TESLA-1',
        currentMileage: 10000.0,
      );

      print('Car added with ID: $carId');

      // Step 2: Get reference to fuel_logs subcollection
      final fuelLogsRef = _carService.getFuelLogsCollection(carId);

      // Step 3: Add a fuel log (example structure)
      await fuelLogsRef.add({
        'date': DateTime.now(),
        'mileage': 10000.0,
        'liters': 0, // EV doesn't use fuel
        'cost': 15.50, // Charging cost
        'notes': 'First charge',
      });

      print('Fuel log added successfully');

      // Step 4: Update car mileage
      await _carService.updateCarMileage(carId, 10050.0);
      print('Car mileage updated');
    } catch (e) {
      print('Error in complete workflow: $e');
    }
  }
}

/// Usage in a Flutter widget or screen:
/// 
/// ```dart
/// class MyCarScreen extends StatefulWidget {
///   @override
///   _MyCarScreenState createState() => _MyCarScreenState();
/// }
/// 
/// class _MyCarScreenState extends State<MyCarScreen> {
///   final CarService _carService = CarService();
///   List<Car> _cars = [];
///   
///   @override
///   void initState() {
///     super.initState();
///     _loadCars();
///   }
///   
///   Future<void> _loadCars() async {
///     try {
///       final cars = await _carService.getAllCars();
///       setState(() {
///         _cars = cars;
///       });
///     } catch (e) {
///       print('Error loading cars: $e');
///     }
///   }
///   
///   Future<void> _addCar() async {
///     try {
///       await _carService.addCar(
///         make: 'Honda',
///         model: 'Civic',
///         year: 2022,
///         fuelType: 'Petrol',
///         registrationNumber: 'ABC-123',
///         currentMileage: 0.0,
///       );
///       _loadCars(); // Reload the list
///     } catch (e) {
///       print('Error adding car: $e');
///     }
///   }
///   
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('My Cars')),
///       body: ListView.builder(
///         itemCount: _cars.length,
///         itemBuilder: (context, index) {
///           final car = _cars[index];
///           return ListTile(
///             title: Text('${car.make} ${car.model}'),
///             subtitle: Text('${car.year} - ${car.registrationNumber}'),
///             trailing: Text('${car.currentMileage} km'),
///           );
///         },
///       ),
///       floatingActionButton: FloatingActionButton(
///         onPressed: _addCar,
///         child: Icon(Icons.add),
///       ),
///     );
///   }
/// }
/// ```

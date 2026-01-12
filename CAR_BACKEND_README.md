# Car Management Backend - Implementation Guide

## Overview

This implementation provides a complete backend solution for managing cars in your Flutter Fuel Tracker app using Cloud Firestore. The system follows the hierarchical structure:

```
users (collection)
 └─ userId (document)
     └─ cars (subcollection)
         ├─ carId1 (document)
         │   ├─ fuel_logs (subcollection)
         │   └─ maintenance_logs (subcollection)
         └─ carId2 (document)
             ├─ fuel_logs (subcollection)
             └─ maintenance_logs (subcollection)
```

## Files Created

### 1. **Car Model** (`lib/models/car.dart`)

The `Car` class represents a car document with all required fields:

- **Fields:**

  - `id` (String?) - Document ID (auto-generated or custom)
  - `make` (String) - Car manufacturer (e.g., Toyota, Ford)
  - `model` (String) - Car model (e.g., Corolla, Mustang)
  - `year` (int) - Manufacturing year
  - `fuelType` (String) - Petrol, Diesel, Hybrid, or EV
  - `registrationNumber` (String) - License plate number
  - `currentMileage` (double) - Latest odometer reading
  - `imageUrl` (String?) - Optional car photo URL
  - `createdAt` (DateTime) - Timestamp when car was added

- **Methods:**
  - `toMap()` - Converts Car object to Firestore-compatible Map
  - `fromMap()` - Creates Car object from Firestore document
  - `copyWith()` - Creates a copy with updated fields
  - `toString()`, `==`, `hashCode` - Standard object methods

### 2. **Car Service** (`lib/services/car_service.dart`)

The `CarService` class provides all backend operations for car management:

#### Core CRUD Operations

- **`addCar()`** - Add a new car with auto-generated ID
- **`addCarWithId()`** - Add a car with a specific custom ID
- **`getCar()`** - Retrieve a specific car by ID
- **`getAllCars()`** - Get all cars for the current user
- **`updateCar()`** - Update any car fields
- **`deleteCar()`** - Delete a car

#### Specialized Update Methods

- **`updateCarMileage()`** - Update only the mileage
- **`updateCarImage()`** - Update only the car image URL

#### Real-time Streaming

- **`streamAllCars()`** - Stream all cars with real-time updates
- **`streamCar()`** - Stream a specific car with real-time updates

#### Helper Methods

- **`carExists()`** - Check if a car exists
- **`getCarsCount()`** - Get total number of cars
- **`getFuelLogsCollection()`** - Get reference to fuel_logs subcollection
- **`getMaintenanceLogsCollection()`** - Get reference to maintenance_logs subcollection

### 3. **Usage Examples** (`lib/services/car_service_examples.dart`)

Comprehensive examples demonstrating all CarService methods with practical use cases.

## Usage Guide

### Basic Usage

#### 1. Add a New Car

```dart
final carService = CarService();

// Add car with auto-generated ID
final carId = await carService.addCar(
  make: 'Toyota',
  model: 'Corolla',
  year: 2020,
  fuelType: 'Petrol',
  registrationNumber: 'ABC-123',
  currentMileage: 50000.0,
  imageUrl: 'https://example.com/car.jpg', // Optional
);

print('Car added with ID: $carId');
```

#### 2. Get All Cars

```dart
final cars = await carService.getAllCars();

for (var car in cars) {
  print('${car.year} ${car.make} ${car.model}');
}
```

#### 3. Update Car Information

```dart
// Update specific fields
await carService.updateCar(
  carId: 'car-id-here',
  currentMileage: 55000.0,
  imageUrl: 'https://example.com/new-image.jpg',
);

// Or use specialized methods
await carService.updateCarMileage('car-id-here', 55000.0);
```

#### 4. Delete a Car

```dart
await carService.deleteCar('car-id-here');
```

### Real-time Updates with Streams

```dart
// Stream all cars
carService.streamAllCars().listen((cars) {
  print('Cars updated: ${cars.length}');
  // Update your UI here
});

// Stream a specific car
carService.streamCar('car-id-here').listen((car) {
  if (car != null) {
    print('Car: ${car.make} ${car.model}');
    // Update your UI here
  }
});
```

### Working with Subcollections

```dart
// Get reference to fuel_logs subcollection
final fuelLogsRef = carService.getFuelLogsCollection('car-id-here');

// Add a fuel log
await fuelLogsRef.add({
  'date': DateTime.now(),
  'mileage': 50000.0,
  'liters': 45.5,
  'cost': 60.00,
  'pricePerLiter': 1.32,
  'notes': 'Full tank',
});

// Query fuel logs
final fuelLogs = await fuelLogsRef
  .orderBy('date', descending: true)
  .limit(10)
  .get();

// Get reference to maintenance_logs subcollection
final maintenanceLogsRef = carService.getMaintenanceLogsCollection('car-id-here');

// Add a maintenance log
await maintenanceLogsRef.add({
  'date': DateTime.now(),
  'type': 'Oil Change',
  'cost': 50.00,
  'mileage': 50000.0,
  'notes': 'Regular maintenance',
});
```

## Integration in Flutter Widgets

### Example: Car List Screen

```dart
class CarListScreen extends StatefulWidget {
  @override
  _CarListScreenState createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final CarService _carService = CarService();
  List<Car> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      final cars = await _carService.getAllCars();
      setState(() {
        _cars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cars: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('My Cars')),
      body: ListView.builder(
        itemCount: _cars.length,
        itemBuilder: (context, index) {
          final car = _cars[index];
          return ListTile(
            leading: car.imageUrl != null
                ? Image.network(car.imageUrl!, width: 50, height: 50)
                : Icon(Icons.directions_car),
            title: Text('${car.make} ${car.model}'),
            subtitle: Text('${car.year} - ${car.registrationNumber}'),
            trailing: Text('${car.currentMileage.toStringAsFixed(0)} km'),
            onTap: () {
              // Navigate to car details
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add car screen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Example: Using StreamBuilder for Real-time Updates

```dart
class CarListStreamScreen extends StatelessWidget {
  final CarService _carService = CarService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Cars (Real-time)')),
      body: StreamBuilder<List<Car>>(
        stream: _carService.streamAllCars(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final cars = snapshot.data ?? [];

          if (cars.isEmpty) {
            return Center(child: Text('No cars added yet'));
          }

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return ListTile(
                title: Text('${car.make} ${car.model}'),
                subtitle: Text('${car.year} - ${car.fuelType}'),
                trailing: Text('${car.currentMileage} km'),
              );
            },
          );
        },
      ),
    );
  }
}
```

## Authentication Requirements

All CarService methods require a user to be authenticated via Firebase Authentication. The service automatically:

1. Gets the current user ID from `FirebaseAuth.instance.currentUser?.uid`
2. Uses this ID to access the user's cars subcollection
3. Throws an exception if no user is authenticated

Make sure users are logged in before calling any CarService methods.

## Error Handling

All methods include try-catch blocks and throw descriptive exceptions:

```dart
try {
  await carService.addCar(...);
} catch (e) {
  // Handle error
  print('Error: $e');
  // Show error to user
}
```

## Firestore Security Rules

Make sure to set up proper Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Allow users to read/write their own document
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Cars subcollection
      match /cars/{carId} {
        // Allow users to read/write their own cars
        allow read, write: if request.auth != null && request.auth.uid == userId;

        // Fuel logs subcollection
        match /fuel_logs/{logId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }

        // Maintenance logs subcollection
        match /maintenance_logs/{logId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
  }
}
```

## Next Steps

Now that the backend is ready, you can:

1. **Create UI screens** for:

   - Adding new cars
   - Viewing car list
   - Editing car details
   - Viewing car details with fuel and maintenance logs

2. **Implement fuel logs service** using the `getFuelLogsCollection()` reference

3. **Implement maintenance logs service** using the `getMaintenanceLogsCollection()` reference

4. **Add image upload functionality** for car photos (using Firebase Storage)

5. **Add validation** for user inputs (e.g., year range, mileage validation)

## Testing

To test the implementation:

1. Make sure Firebase is properly configured
2. Ensure a user is authenticated
3. Use the examples in `car_service_examples.dart` as reference
4. Test each operation individually

```dart
// Quick test
final carService = CarService();

// Add a test car
final carId = await carService.addCar(
  make: 'Test',
  model: 'Car',
  year: 2024,
  fuelType: 'Petrol',
  registrationNumber: 'TEST-123',
  currentMileage: 0.0,
);

// Verify it was added
final car = await carService.getCar(carId);
print('Car added: ${car?.make} ${car?.model}');

// Clean up
await carService.deleteCar(carId);
```

## Summary

✅ **Car Model** - Complete with all required fields and Firestore integration
✅ **Car Service** - Comprehensive CRUD operations and real-time streaming
✅ **Examples** - Detailed usage examples for all methods
✅ **Documentation** - Complete guide for implementation

The backend is now ready for UI integration!

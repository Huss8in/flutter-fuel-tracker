import 'package:flutter/foundation.dart';
import '../models/car.dart';
import '../services/car_service.dart';

class CarProvider extends ChangeNotifier {
  final CarService _carService = CarService();

  List<Car> _cars = [];
  String? _selectedCarId;
  bool _isLoading = false;

  List<Car> get cars => _cars;
  String? get selectedCarId => _selectedCarId;
  bool get isLoading => _isLoading;

  Car? get selectedCar {
    if (_selectedCarId == null || _cars.isEmpty) return null;
    try {
      return _cars.firstWhere((car) => car.id == _selectedCarId);
    } catch (_) {
      return _cars.first;
    }
  }

  Future<void> fetchCars() async {
    _isLoading = true;
    try {
      _cars = await _carService.getAllCars();
      if (_cars.isNotEmpty && _selectedCarId == null) {
        _selectedCarId = _cars.first.id;
      }
    } catch (e) {
      debugPrint('Error fetching cars: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedCar(String carId) {
    _selectedCarId = carId;
    notifyListeners();
  }

  Future<void> addCar(Car car) async {
    _setLoading(true);
    try {
      final carId = await _carService.addCar(
        make: car.make,
        model: car.model,
        year: car.year,
        fuelType: car.fuelType,
        registrationNumber: car.registrationNumber,
        currentMileage: car.currentMileage,
        imageUrl: car.imageUrl,
      );

      // Refresh list
      await fetchCars();
      _selectedCarId = carId;
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding car: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Method to clear state on logout
  void clear() {
    _cars = [];
    _selectedCarId = null;
    notifyListeners();
  }
}

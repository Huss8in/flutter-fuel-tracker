import 'package:flutter/foundation.dart';
import '../models/maintenance_log.dart';

class MaintenanceProvider extends ChangeNotifier {
  List<MaintenanceLog> _maintenanceLogs = [];

  List<MaintenanceLog> get maintenanceLogs => _maintenanceLogs;

  MaintenanceProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _maintenanceLogs = [
      MaintenanceLog(
        id: '1',
        date: DateTime(2025, 1, 15),
        type: 'Oil Change',
        odometer: 395000,
        cost: 450.0,
        serviceCenter: 'Quick Service Center',
        notes: 'Full synthetic oil used',
      ),
      MaintenanceLog(
        id: '2',
        date: DateTime(2025, 3, 10),
        type: 'Tire Rotation',
        odometer: 398000,
        cost: 200.0,
        serviceCenter: 'Tire Masters',
        notes: 'All tires rotated and balanced',
      ),
      MaintenanceLog(
        id: '3',
        date: DateTime(2025, 5, 20),
        type: 'Brake Inspection',
        odometer: 400000,
        cost: 150.0,
        serviceCenter: 'Auto Care Plus',
        notes: 'Brake pads at 40% - good condition',
      ),
      MaintenanceLog(
        id: '4',
        date: DateTime(2025, 7, 5),
        type: 'Air Filter Replacement',
        odometer: 402500,
        cost: 120.0,
        serviceCenter: 'Quick Service Center',
        notes: 'Engine and cabin air filters replaced',
      ),
      MaintenanceLog(
        id: '5',
        date: DateTime(2025, 8, 12),
        type: 'Oil Change',
        odometer: 404000,
        cost: 450.0,
        serviceCenter: 'Quick Service Center',
        notes: 'Regular maintenance service',
      ),
    ];

    // Sort by date (most recent first)
    _maintenanceLogs.sort((a, b) => b.date.compareTo(a.date));
    debugPrint('✅ Mock maintenance data loaded: ${_maintenanceLogs.length} logs');
  }

  void addMaintenanceLog({
    required DateTime date,
    required String type,
    required int odometer,
    required double cost,
    String? serviceCenter,
    String? notes,
  }) {
    final newLog = MaintenanceLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      type: type,
      odometer: odometer,
      cost: cost,
      serviceCenter: serviceCenter,
      notes: notes,
    );

    _maintenanceLogs.add(newLog);
    _maintenanceLogs.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();

    // TODO: When Firebase is connected, save to:
    // users/{userId}/cars/{carId}/maintenance_logs/{maintenanceId}
  }

  void deleteMaintenanceLog(String id) {
    _maintenanceLogs.removeWhere((log) => log.id == id);
    notifyListeners();

    // TODO: When Firebase is connected, delete from:
    // users/{userId}/cars/{carId}/maintenance_logs/{maintenanceId}
  }

  void updateMaintenanceLog({
    required String id,
    required DateTime date,
    required String type,
    required int odometer,
    required double cost,
    String? serviceCenter,
    String? notes,
  }) {
    final index = _maintenanceLogs.indexWhere((log) => log.id == id);
    if (index != -1) {
      _maintenanceLogs[index] = MaintenanceLog(
        id: id,
        date: date,
        type: type,
        odometer: odometer,
        cost: cost,
        serviceCenter: serviceCenter,
        notes: notes,
      );
      _maintenanceLogs.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();

      // TODO: When Firebase is connected, update at:
      // users/{userId}/cars/{carId}/maintenance_logs/{maintenanceId}
    }
  }

  // Get total maintenance cost
  double get totalMaintenanceCost {
    return _maintenanceLogs.fold(0.0, (sum, log) => sum + log.cost);
  }

  // Get maintenance logs by type
  List<MaintenanceLog> getLogsByType(String type) {
    return _maintenanceLogs.where((log) => log.type == type).toList();
  }

  // Get unique maintenance types
  List<String> get maintenanceTypes {
    return _maintenanceLogs.map((log) => log.type).toSet().toList()..sort();
  }
}

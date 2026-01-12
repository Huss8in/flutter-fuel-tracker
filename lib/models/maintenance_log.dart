class MaintenanceLog {
  final String id;
  final DateTime date;
  final String type;
  final int odometer;
  final double cost;
  final String? serviceCenter;
  final String? notes;

  MaintenanceLog({
    required this.id,
    required this.date,
    required this.type,
    required this.odometer,
    required this.cost,
    this.serviceCenter,
    this.notes,
  });

  factory MaintenanceLog.fromJson(Map<String, dynamic> json) {
    return MaintenanceLog(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      odometer: json['odometer'],
      cost: (json['cost'] as num).toDouble(),
      serviceCenter: json['serviceCenter'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'odometer': odometer,
      'cost': cost,
      'serviceCenter': serviceCenter,
      'notes': notes,
    };
  }

  // Firebase-ready path structure for reference:
  // users/{userId}/cars/{carId}/maintenance_logs/{maintenanceId}
  // This will be used when connecting to Firebase
}

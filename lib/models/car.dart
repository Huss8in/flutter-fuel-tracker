import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String? id;
  final String make;
  final String model;
  final int year;
  final String fuelType;
  final String registrationNumber;
  final double currentMileage;
  final String? imageUrl;
  final DateTime createdAt;

  Car({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.fuelType,
    required this.registrationNumber,
    required this.currentMileage,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Car object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'fuelType': fuelType,
      'registrationNumber': registrationNumber,
      'currentMileage': currentMileage,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create Car object from Firestore document
  factory Car.fromMap(Map<String, dynamic> map, String documentId) {
    return Car(
      id: documentId,
      make: map['make'] as String? ?? '',
      model: map['model'] as String? ?? '',
      year: map['year'] as int? ?? 0,
      fuelType: map['fuelType'] as String? ?? '',
      registrationNumber: map['registrationNumber'] as String? ?? '',
      currentMileage: (map['currentMileage'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create a copy of Car with updated fields
  Car copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? fuelType,
    String? registrationNumber,
    double? currentMileage,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Car(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      fuelType: fuelType ?? this.fuelType,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      currentMileage: currentMileage ?? this.currentMileage,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Car(id: $id, make: $make, model: $model, year: $year, fuelType: $fuelType, registrationNumber: $registrationNumber, currentMileage: $currentMileage, imageUrl: $imageUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Car &&
        other.id == id &&
        other.make == make &&
        other.model == model &&
        other.year == year &&
        other.fuelType == fuelType &&
        other.registrationNumber == registrationNumber &&
        other.currentMileage == currentMileage &&
        other.imageUrl == imageUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        make.hashCode ^
        model.hashCode ^
        year.hashCode ^
        fuelType.hashCode ^
        registrationNumber.hashCode ^
        currentMileage.hashCode ^
        imageUrl.hashCode ^
        createdAt.hashCode;
  }
}

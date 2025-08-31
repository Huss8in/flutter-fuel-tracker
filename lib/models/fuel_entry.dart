class FuelEntry {
  final String id;
  final DateTime date;
  final int kilometerReading;
  final double priceEGP;
  final double literPriceEGP;
  final double liters;
  final int kilometersDriven;
  final double fuelConsumptionKmPerL;
  final double litersPer100Km;
  final int daysSinceLastRefill;

  FuelEntry({
    required this.id,
    required this.date,
    required this.kilometerReading,
    required this.priceEGP,
    required this.literPriceEGP,
    required this.liters,
    required this.kilometersDriven,
    required this.fuelConsumptionKmPerL,
    required this.litersPer100Km,
    required this.daysSinceLastRefill,
  });

  factory FuelEntry.fromJson(Map<String, dynamic> json) {
    return FuelEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      kilometerReading: json['kilometerReading'],
      priceEGP: json['priceEGP'],
      literPriceEGP: json['literPriceEGP'],
      liters: json['liters'],
      kilometersDriven: json['kilometersDriven'],
      fuelConsumptionKmPerL: json['fuelConsumptionKmPerL'],
      litersPer100Km: json['litersPer100Km'],
      daysSinceLastRefill: json['daysSinceLastRefill'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'kilometerReading': kilometerReading,
      'priceEGP': priceEGP,
      'literPriceEGP': literPriceEGP,
      'liters': liters,
      'kilometersDriven': kilometersDriven,
      'fuelConsumptionKmPerL': fuelConsumptionKmPerL,
      'litersPer100Km': litersPer100Km,
      'daysSinceLastRefill': daysSinceLastRefill,
    };
  }

  static FuelEntry calculateEntry({
    required String id,
    required DateTime date,
    required int kilometerReading,
    required double priceEGP,
    required double literPriceEGP,
    FuelEntry? previousEntry,
  }) {
    final liters = priceEGP / literPriceEGP;
    
    int kilometersDriven = 0;
    double fuelConsumptionKmPerL = 0;
    double litersPer100Km = 0;
    int daysSinceLastRefill = 0;

    if (previousEntry != null) {
      kilometersDriven = kilometerReading - previousEntry.kilometerReading;
      fuelConsumptionKmPerL = kilometersDriven > 0 ? kilometersDriven / liters : 0;
      litersPer100Km = kilometersDriven > 0 ? (100 * liters) / kilometersDriven : 0;
      daysSinceLastRefill = date.difference(previousEntry.date).inDays;
    }

    return FuelEntry(
      id: id,
      date: date,
      kilometerReading: kilometerReading,
      priceEGP: priceEGP,
      literPriceEGP: literPriceEGP,
      liters: liters,
      kilometersDriven: kilometersDriven,
      fuelConsumptionKmPerL: fuelConsumptionKmPerL,
      litersPer100Km: litersPer100Km,
      daysSinceLastRefill: daysSinceLastRefill,
    );
  }
}
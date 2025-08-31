import 'fuel_entry.dart';

class FuelSummary {
  final int totalEntries;
  final double totalSpent;
  final double totalLiters;
  final int totalKilometersDriven;
  final double averageFuelConsumption;
  final double averageLitersPer100Km;
  final double averagePricePerLiter;
  final int daysCovered;

  FuelSummary({
    required this.totalEntries,
    required this.totalSpent,
    required this.totalLiters,
    required this.totalKilometersDriven,
    required this.averageFuelConsumption,
    required this.averageLitersPer100Km,
    required this.averagePricePerLiter,
    required this.daysCovered,
  });

  static FuelSummary calculate(List<FuelEntry> entries) {
    if (entries.isEmpty) {
      return FuelSummary(
        totalEntries: 0,
        totalSpent: 0,
        totalLiters: 0,
        totalKilometersDriven: 0,
        averageFuelConsumption: 0,
        averageLitersPer100Km: 0,
        averagePricePerLiter: 0,
        daysCovered: 0,
      );
    }

    final totalSpent = entries.fold(0.0, (sum, entry) => sum + entry.priceEGP);
    final totalLiters = entries.fold(0.0, (sum, entry) => sum + entry.liters);
    final totalKilometersDriven = entries.fold(0, (sum, entry) => sum + entry.kilometersDriven);
    
    final validConsumptionEntries = entries.where((e) => e.fuelConsumptionKmPerL > 0).toList();
    final averageFuelConsumption = validConsumptionEntries.isNotEmpty
        ? validConsumptionEntries.fold(0.0, (sum, entry) => sum + entry.fuelConsumptionKmPerL) / validConsumptionEntries.length
        : 0.0;

    final validLitersPer100KmEntries = entries.where((e) => e.litersPer100Km > 0).toList();
    final averageLitersPer100Km = validLitersPer100KmEntries.isNotEmpty
        ? validLitersPer100KmEntries.fold(0.0, (sum, entry) => sum + entry.litersPer100Km) / validLitersPer100KmEntries.length
        : 0.0;

    final averagePricePerLiter = totalLiters > 0 ? totalSpent / totalLiters : 0.0;

    final sortedEntries = entries.toList()..sort((a, b) => a.date.compareTo(b.date));
    final daysCovered = sortedEntries.isNotEmpty
        ? sortedEntries.last.date.difference(sortedEntries.first.date).inDays + 1
        : 0;

    return FuelSummary(
      totalEntries: entries.length,
      totalSpent: totalSpent,
      totalLiters: totalLiters,
      totalKilometersDriven: totalKilometersDriven,
      averageFuelConsumption: averageFuelConsumption,
      averageLitersPer100Km: averageLitersPer100Km,
      averagePricePerLiter: averagePricePerLiter,
      daysCovered: daysCovered,
    );
  }
}
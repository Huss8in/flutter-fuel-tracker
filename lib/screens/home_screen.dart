import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_summary.dart';
import '../utils/date_range.dart';
import '../widgets/simple_swipe_card.dart';
import 'add_fuel_entry_screen.dart';
import 'edit_fuel_entry_screen.dart';

class FuelTrackerHome extends StatelessWidget {
  const FuelTrackerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('🚗 Fuel Tracker'),
      ),
      body: Consumer<FuelProvider>(
        builder: (context, fuelProvider, child) {
          if (fuelProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                // Date Range Selector - Apple Style
                Container(
                  margin: EdgeInsets.fromLTRB(
                    16.0,
                    16.0,
                    16.0,
                    8.0,
                  ),
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width < 600 ? 16.0 : 20.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width < 600 ? 16 : 20,
                    ),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.date_range_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Time Period',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            flex: 2,
                            child: DropdownButton<DateRange>(
                              value: fuelProvider.selectedDateRange,
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              onChanged: (DateRange? newValue) {
                                if (newValue != null) {
                                  if (newValue == DateRange.custom) {
                                    _showCustomDateRangeDialog(context, fuelProvider);
                                  } else {
                                    fuelProvider.setDateRange(newValue);
                                  }
                                }
                              },
                              items: DateRange.values.map<DropdownMenuItem<DateRange>>((DateRange value) {
                                return DropdownMenuItem<DateRange>(
                                  value: value,
                                  child: Text(value.label),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      if (fuelProvider.selectedDateRange == DateRange.custom && 
                          fuelProvider.customStartDate != null && 
                          fuelProvider.customEndDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Custom: ${fuelProvider.customStartDate!.day}/${fuelProvider.customStartDate!.month}/${fuelProvider.customStartDate!.year} - ${fuelProvider.customEndDate!.day}/${fuelProvider.customEndDate!.month}/${fuelProvider.customEndDate!.year}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              
              // Summary Section - Apple Style
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 600 ? 16.0 : 24.0,
                ),
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 600 ? 20.0 : 24.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.05),
                      Theme.of(context).primaryColor.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width < 600 ? 20 : 24,
                  ),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 24,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSummaryGrid(fuelProvider.summary),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Entries List - Apple Style
              Expanded(
                child: fuelProvider.filteredEntries.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_gas_station_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No entries for selected period',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add your first entry!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width < 600 ? 16.0 : 24.0,
                          8.0,
                          MediaQuery.of(context).size.width < 600 ? 16.0 : 24.0,
                          MediaQuery.of(context).padding.bottom + 16.0,
                        ),
                        itemCount: fuelProvider.filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = fuelProvider.filteredEntries[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: SimpleSwipeCard(
                              entry: entry,
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditFuelEntryScreen(entry: entry),
                                  ),
                                );
                              },
                              onDelete: () async {
                                final shouldDelete = await _showDeleteConfirmation(context);
                                if (shouldDelete == true) {
                                  fuelProvider.deleteEntry(entry.id);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddFuelEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryGrid(FuelSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Apple-style responsive breakpoints
        final screenWidth = constraints.maxWidth;
        final isPhone = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1000;
        
        // Dynamic grid layout based on screen size
        final crossAxisCount = isPhone ? 2 : (isTablet ? 3 : 4);
        final spacing = isPhone ? 12.0 : (isTablet ? 16.0 : 20.0);
        final itemAspectRatio = isPhone ? 2.2 : (isTablet ? 1.8 : 1.6);
        
        final summaryItems = [
          _SummaryData('📊 Entries', summary.totalEntries.toString(), Icons.assessment_outlined),
          _SummaryData('💲 Total Spent', '${summary.totalSpent.toStringAsFixed(2)} EGP', Icons.payments_outlined),
          _SummaryData('⛽ Total Liters', '${summary.totalLiters.toStringAsFixed(2)} L', Icons.local_gas_station_outlined),
          _SummaryData('🚗 Km Driven', '${summary.totalKilometersDriven} km', Icons.speed_outlined),
          _SummaryData('💰 Avg Price/L', '${summary.averagePricePerLiter.toStringAsFixed(2)} EGP', Icons.trending_up_outlined),
          _SummaryData('⛽ Avg km/L', summary.averageFuelConsumption > 0 ? summary.averageFuelConsumption.toStringAsFixed(2) : 'N/A', Icons.eco_outlined),
          _SummaryData('🚗⛽ Avg L/100km', summary.averageLitersPer100Km > 0 ? summary.averageLitersPer100Km.toStringAsFixed(2) : 'N/A', Icons.analytics_outlined),
          _SummaryData('📅 Days', '${summary.daysCovered}', Icons.calendar_month_outlined),
        ];
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: itemAspectRatio,
          ),
          itemCount: summaryItems.length,
          itemBuilder: (context, index) {
            final item = summaryItems[index];
            return _buildAppleSummaryCard(item, isPhone, isTablet, context);
          },
        );
      },
    );
  }

  Widget _buildAppleSummaryCard(_SummaryData data, bool isPhone, bool isTablet, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isPhone ? 12.0 : (isTablet ? 16.0 : 20.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isPhone ? 16 : (isTablet ? 18 : 20)),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            spreadRadius: 0,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            data.icon,
            size: isPhone ? 20 : (isTablet ? 24 : 28),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ),
          SizedBox(height: isPhone ? 6 : (isTablet ? 8 : 10)),
          Flexible(
            child: Text(
              data.label.replaceAll(RegExp(r'[🚗💲⛽📊💰📅]'), '').trim(),
              style: TextStyle(
                fontSize: isPhone ? 11 : (isTablet ? 12 : 13),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: isPhone ? 4 : (isTablet ? 6 : 8)),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                data.value,
                style: TextStyle(
                  fontSize: isPhone ? 16 : (isTablet ? 18 : 20),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomDateRangeDialog(BuildContext context, FuelProvider provider) {
    DateTime startDate = provider.customStartDate ?? DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = provider.customEndDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Custom Date Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Start Date: ${startDate.day}/${startDate.month}/${startDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: endDate,
                  );
                  if (date != null) {
                    setState(() {
                      startDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('End Date: ${endDate.day}/${endDate.month}/${endDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: startDate,
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      endDate = date;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setCustomDateRange(startDate, endDate);
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this fuel entry? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryData {
  final String label;
  final String value;
  final IconData icon;
  
  _SummaryData(this.label, this.value, this.icon);
}
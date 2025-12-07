import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../models/fuel_summary.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _showAllEntries = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<FuelProvider>(
      builder: (context, fuelProvider, child) {
        if (fuelProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final isVerySmall = screenWidth < 350;
        final isSmall = screenWidth < 600;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(
            isVerySmall ? 12.0 : isSmall ? 16.0 : 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Statistics Cards
              _buildStatsCards(fuelProvider.summary),
              SizedBox(height: isVerySmall ? 16 : 24),
              
              // Summary Table
              _buildSummaryTable(context, fuelProvider),
              SizedBox(height: isVerySmall ? 16 : 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(FuelSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isVerySmall = screenWidth < 450;
        final crossAxisCount = 1; // Always 2 columns as requested
        final aspectRatio = isVerySmall ? 2.8 : 2.2;
        final spacing = isVerySmall ? 8.0 : 12.0;
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
            children: [
              _buildStatCard(
                '📊 Total Entries',
                summary.totalEntries.toString(),
                Icons.assessment_outlined,
                Colors.blue,
                isVerySmall,
              ),
              _buildStatCard(
                '💲 Total Spent',
                '${summary.totalSpent.toStringAsFixed(0)} EGP',
                Icons.payments_outlined,
                Colors.green,
                isVerySmall,
              ),
              _buildStatCard(
                '🚗 Km Driven',
                '${summary.totalKilometersDriven.toStringAsFixed(0)} km',
                Icons.speed_outlined,
                Colors.orange,
                isVerySmall,
              ),
              _buildStatCard(
                '⛽ Avg L/100km',
                summary.averageLitersPer100Km > 0 
                    ? summary.averageLitersPer100Km.toStringAsFixed(1)
                    : 'N/A',
                Icons.eco_outlined,
                Colors.purple,
                isVerySmall,
              ),
            ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.all(isVerySmall ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isVerySmall ? 12 : 16),
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
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isVerySmall ? 20 : 24,
            color: color,
          ),
          SizedBox(height: isVerySmall ? 6 : 8),
          Text(
            title.replaceAll(RegExp(r'[📊💲🚗⛽]'), '').trim(),
            style: TextStyle(
              fontSize: isVerySmall ? 10 : 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isVerySmall ? 3 : 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isVerySmall ? 14 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTable(BuildContext context, FuelProvider fuelProvider) {
    final allEntries = fuelProvider.filteredEntries;
    final entries = _showAllEntries ? allEntries : allEntries.take(5).toList();
    final hasMore = allEntries.length > 5;
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 350;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.all(isVerySmall ? 12.0 : 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.table_chart_outlined,
                  color: Theme.of(context).primaryColor,
                  size: isVerySmall ? 18 : 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isVerySmall ? 'Entries' : 'Fuel Entries Summary',
                    style: TextStyle(
                      fontSize: isVerySmall ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Table Content
          entries.isEmpty 
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildTableContent(entries),
                    if (hasMore) _buildToggleButton(context, allEntries.length),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, int totalEntries) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            _showAllEntries = !_showAllEntries;
          });
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          backgroundColor: Colors.blue.withValues(alpha: 0.05),
          foregroundColor: Colors.blue[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _showAllEntries 
                  ? 'Show Less'
                  : 'See All $totalEntries Entries',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              _showAllEntries 
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.blue[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.table_chart_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No entries for selected period',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableContent(List entries) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isVerySmall = screenWidth < 350;
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth,
            ),
            child: DataTable(
              columnSpacing: isVerySmall ? 8 : 16,
              horizontalMargin: isVerySmall ? 6 : 12,
              headingRowColor: WidgetStateColor.resolveWith(
                (states) => Colors.grey.withValues(alpha: 0.05),
              ),
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isVerySmall ? 10 : 12,
                letterSpacing: -0.2,
              ),
              dataTextStyle: TextStyle(
                fontSize: isVerySmall ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
        columns: const [
          DataColumn(
            label: Text('Date'),
          ),
          DataColumn(
            label: Text('Usage\n(L/100km)'),
            numeric: true,
          ),
          DataColumn(
            label: Text('Km Driven'),
            numeric: true,
          ),
          DataColumn(
            label: Text('Money Spent\n(EGP)'),
            numeric: true,
          ),
          DataColumn(
            label: Text('Liters'),
            numeric: true,
          ),
        ],
        rows: entries.map<DataRow>((entry) {
          return DataRow(
            cells: [
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              DataCell(
                Text(
                  entry.litersPer100Km > 0 
                      ? '${entry.litersPer100Km.toStringAsFixed(1)}'
                      : 'N/A',
                  style: TextStyle(
                    color: entry.litersPer100Km > 0 
                        ? (entry.litersPer100Km > 10 ? Colors.red[600] : Colors.green[600])
                        : Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${entry.kilometersDriven}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(
                  '${entry.priceEGP.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${entry.liters.toStringAsFixed(1)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          );
        }).toList(),
            ),
          ),
        );
      },
    );
  }
}
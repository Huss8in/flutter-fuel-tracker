import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../widgets/simple_swipe_card.dart';
import 'edit_fuel_entry_screen.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FuelProvider>(
      builder: (context, fuelProvider, child) {
        if (fuelProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return fuelProvider.filteredEntries.isEmpty
            ? _buildEmptyState(context)
            : _buildLogsList(context, fuelProvider);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No entries for selected period',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
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
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList(BuildContext context, FuelProvider fuelProvider) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.of(context).size.width < 600 ? 16.0 : 24.0,
        16.0,
        MediaQuery.of(context).size.width < 600 ? 16.0 : 24.0,
        MediaQuery.of(context).padding.bottom + 100.0, // Space for FAB
      ),
      itemCount: fuelProvider.filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = fuelProvider.filteredEntries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildLogCard(context, entry, fuelProvider),
        );
      },
    );
  }

  Widget _buildLogCard(BuildContext context, dynamic entry, FuelProvider fuelProvider) {
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
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Entry',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this fuel entry? This action cannot be undone.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[500],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
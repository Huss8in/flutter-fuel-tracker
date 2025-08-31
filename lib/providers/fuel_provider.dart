import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fuel_entry.dart';
import '../models/fuel_summary.dart';
import '../utils/date_range.dart';
import '../services/firebase_service.dart';

class FuelProvider extends ChangeNotifier {
  List<FuelEntry> _entries = [];
  final bool _isLoading = false;
  DateRange _selectedDateRange = DateRange.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isAscending = false;
  final FirebaseService _firebaseService = FirebaseService();

  List<FuelEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  DateRange get selectedDateRange => _selectedDateRange;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  bool get isAscending => _isAscending;

  List<FuelEntry> get filteredEntries {
    List<FuelEntry> filtered = List.from(_entries);

    // Debug: Print total entries and selected date range
    debugPrint('🔍 Total entries: ${_entries.length}, Selected range: $_selectedDateRange');

    // Apply date filtering if not showing all entries
    if (_selectedDateRange != DateRange.all) {
      final now = DateTime.now();
      DateTime? startDate;
      DateTime? endDate;

      switch (_selectedDateRange) {
        case DateRange.week:
          startDate = now.subtract(Duration(days: now.weekday - 1));
          endDate = now;
          break;
        case DateRange.month:
          startDate = DateTime(now.year, now.month, 1);
          endDate = now;
          break;
        case DateRange.quarter:
          final quarterStart = ((now.month - 1) ~/ 3) * 3 + 1;
          startDate = DateTime(now.year, quarterStart, 1);
          endDate = now;
          break;
        case DateRange.year:
          startDate = DateTime(now.year, 1, 1);
          endDate = now;
          break;
        case DateRange.custom:
          if (_customStartDate != null && _customEndDate != null) {
            startDate = _customStartDate!;
            endDate = _customEndDate!;
          }
          break;
        case DateRange.all:
          // Show all entries - no filtering
          break;
      }

      // Apply date filtering only if we have valid start and end dates
      if (startDate != null && endDate != null) {
        debugPrint('🗓️ Filter range: $startDate to $endDate');
        
        filtered = _entries.where((entry) {
          // Normalize dates to compare only year-month-day (ignore time)
          final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
          final filterStartDate = DateTime(startDate!.year, startDate.month, startDate.day);
          final filterEndDate = DateTime(endDate!.year, endDate.month, endDate.day);
          
          final isInRange = (entryDate.isAtSameMomentAs(filterStartDate) || entryDate.isAfter(filterStartDate)) &&
                           (entryDate.isAtSameMomentAs(filterEndDate) || entryDate.isBefore(filterEndDate));
          
          if (!isInRange) {
            debugPrint('❌ Entry ${entry.id} (${entry.date}) excluded from range');
          }
          
          return isInRange;
        }).toList();
        
        debugPrint('✅ Filtered entries: ${filtered.length}');
      }
    } else {
      debugPrint('📋 Showing all entries (no filtering applied)');
    }

    // Apply sorting
    filtered.sort((a, b) {
      final comparison = a.date.compareTo(b.date);
      return _isAscending ? comparison : -comparison;
    });

    debugPrint('🎯 Final filtered entries: ${filtered.length}');
    return filtered;
  }

  FuelSummary get summary => FuelSummary.calculate(filteredEntries);

  FuelProvider() {
    debugPrint('🏗️ FuelProvider instance created');
    // Load dummy data immediately - no async needed
    _loadDummyData();
    // Then try to load from Firebase/local storage in background
    _loadDataInBackground();
  }

  void setDateRange(DateRange range) {
    debugPrint('🔄 Date range changed from $_selectedDateRange to $range');
    _selectedDateRange = range;
    notifyListeners();
  }

  void setCustomDateRange(DateTime startDate, DateTime endDate) {
    _customStartDate = startDate;
    _customEndDate = endDate;
    _selectedDateRange = DateRange.custom;
    notifyListeners();
  }

  void setSortOrder(bool isAscending) {
    _isAscending = isAscending;
    notifyListeners();
  }

  Future<void> _loadDataInBackground() async {
    // DISABLED: Don't load from Firebase/storage to keep dummy data
    // This prevents the 3 real entries from overwriting our 24 dummy entries
    debugPrint('🚫 Background loading disabled to preserve dummy data');
    return;
    
    // Try to load from Firebase in background
    try {
      final entriesData = await _firebaseService.loadFuelEntries();
      if (entriesData.isNotEmpty) {
        _entries = entriesData.map((json) => FuelEntry.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Firebase load error: $e');
      await _loadFromLocalStorage();
    }
  }

  void _loadDummyData() {
    final now = DateTime.now();
    debugPrint('🔄 Loading dummy data...');

    _entries = [
      FuelEntry.calculateEntry(
        id: '1',
        date: DateTime(2025, 1, 9),
        kilometerReading: 394969,
        priceEGP: 584.0,
        literPriceEGP: 15.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '2',
        date: DateTime(2025, 1, 20),
        kilometerReading: 395465,
        priceEGP: 585.0,
        literPriceEGP: 15.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '3',
        date: DateTime(2025, 2, 7),
        kilometerReading: 395899,
        priceEGP: 581.0,
        literPriceEGP: 15.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '4',
        date: DateTime(2025, 2, 15),
        kilometerReading: 396340,
        priceEGP: 560.0,
        literPriceEGP: 15.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '5',
        date: DateTime(2025, 2, 20),
        kilometerReading: 396731,
        priceEGP: 535.0,
        literPriceEGP: 15.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '6',
        date: DateTime(2025, 2, 28),
        kilometerReading: 397205,
        priceEGP: 557.0,
        literPriceEGP: 15.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '7',
        date: DateTime(2025, 3, 12),
        kilometerReading: 397603,
        priceEGP: 565.0,
        literPriceEGP: 15.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '8',
        date: DateTime(2025, 3, 21),
        kilometerReading: 397995,
        priceEGP: 570.0,
        literPriceEGP: 15.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '9',
        date: DateTime(2025, 3, 30),
        kilometerReading: 398378,
        priceEGP: 566.0,
        literPriceEGP: 15.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '10',
        date: DateTime(2025, 4, 11),
        kilometerReading: 398791,
        priceEGP: 640.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '11',
        date: DateTime(2025, 4, 26),
        kilometerReading: 399208,
        priceEGP: 650.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '12',
        date: DateTime(2025, 5, 3),
        kilometerReading: 399577,
        priceEGP: 543.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '13',
        date: DateTime(2025, 5, 27),
        kilometerReading: 400414,
        priceEGP: 654.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '14',
        date: DateTime(2025, 6, 1),
        kilometerReading: 400784,
        priceEGP: 571.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '15',
        date: DateTime(2025, 6, 18),
        kilometerReading: 401137,
        priceEGP: 570.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '16',
        date: DateTime(2025, 6, 24),
        kilometerReading: 401485,
        priceEGP: 566.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '17',
        date: DateTime(2025, 6, 29),
        kilometerReading: 401833,
        priceEGP: 455.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '18',
        date: DateTime(2025, 7, 8),
        kilometerReading: 402224,
        priceEGP: 500.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '19',
        date: DateTime(2025, 7, 17),
        kilometerReading: 402656,
        priceEGP: 510.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '20',
        date: DateTime(2025, 7, 21),
        kilometerReading: 403004,
        priceEGP: 510.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '21',
        date: DateTime(2025, 7, 31),
        kilometerReading: 403412,
        priceEGP: 650.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '22',
        date: DateTime(2025, 8, 9),
        kilometerReading: 403604,
        priceEGP: 355.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '23',
        date: DateTime(2025, 8, 13),
        kilometerReading: 404028,
        priceEGP: 600.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
      FuelEntry.calculateEntry(
        id: '24',
        date: DateTime(2025, 8, 16),
        kilometerReading: 404372,
        priceEGP: 525.0,
        literPriceEGP: 17.25,
        previousEntry: null,
      ),
    ];

    for (int i = 1; i < _entries.length; i++) {
      final previousEntry = _entries[i - 1];
      final currentEntry = _entries[i];

      _entries[i] = FuelEntry.calculateEntry(
        id: currentEntry.id,
        date: currentEntry.date,
        kilometerReading: currentEntry.kilometerReading,
        priceEGP: currentEntry.priceEGP,
        literPriceEGP: currentEntry.literPriceEGP,
        previousEntry: previousEntry,
      );
    }
    
    debugPrint('✅ Dummy data loaded: ${_entries.length} entries');
    debugPrint('📅 Date range: ${_entries.first.date} to ${_entries.last.date}');
  }

  Future<void> _saveEntries() async {
    try {
      final entriesData = _entries.map((e) => e.toJson()).toList();
      await _firebaseService.saveFuelEntries(entriesData);
      await _saveToLocalStorage();
    } catch (e) {
      debugPrint('Firebase save error: $e');
      await _saveToLocalStorage();
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getString('fuel_entries');

      if (entriesJson != null) {
        final List<dynamic> decoded = jsonDecode(entriesJson);
        _entries = decoded.map((json) => FuelEntry.fromJson(json)).toList();
      } else {
        _loadDummyData();
      }
    } catch (e) {
      _loadDummyData();
    }
  }

  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString('fuel_entries', entriesJson);
    } catch (e) {
      debugPrint('Local storage save error: $e');
    }
  }

  void addEntry({
    required DateTime date,
    required int kilometerReading,
    required double priceEGP,
    required double literPriceEGP,
  }) {
    final previousEntry = _entries.isNotEmpty ? _entries.last : null;

    final newEntry = FuelEntry.calculateEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      kilometerReading: kilometerReading,
      priceEGP: priceEGP,
      literPriceEGP: literPriceEGP,
      previousEntry: previousEntry,
    );

    _entries.add(newEntry);
    _saveEntries();
    notifyListeners();
  }

  double get lastLiterPrice =>
      _entries.isNotEmpty ? _entries.last.literPriceEGP : 12.5;

  void deleteEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveEntries();
    notifyListeners();
  }

  void updateEntry({
    required String id,
    required DateTime date,
    required int kilometerReading,
    required double priceEGP,
    required double literPriceEGP,
  }) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      final previousEntry = index > 0 ? _entries[index - 1] : null;

      final updatedEntry = FuelEntry.calculateEntry(
        id: id,
        date: date,
        kilometerReading: kilometerReading,
        priceEGP: priceEGP,
        literPriceEGP: literPriceEGP,
        previousEntry: previousEntry,
      );

      _entries[index] = updatedEntry;

      // Recalculate subsequent entries if needed
      for (int i = index + 1; i < _entries.length; i++) {
        final current = _entries[i];
        final previous = _entries[i - 1];

        _entries[i] = FuelEntry.calculateEntry(
          id: current.id,
          date: current.date,
          kilometerReading: current.kilometerReading,
          priceEGP: current.priceEGP,
          literPriceEGP: current.literPriceEGP,
          previousEntry: previous,
        );
      }

      _saveEntries();
      notifyListeners();
    }
  }
}

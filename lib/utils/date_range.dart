enum DateRange { all, week, month, quarter, year, custom }

extension DateRangeExtension on DateRange {
  String get label {
    switch (this) {
      case DateRange.all:
        return 'All Time';
      case DateRange.week:
        return 'This Week';
      case DateRange.month:
        return 'This Month';
      case DateRange.quarter:
        return 'This Quarter';
      case DateRange.year:
        return 'This Year';
      case DateRange.custom:
        return 'Custom Range';
    }
  }
}
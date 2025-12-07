# Fuel Tracker

A Flutter application for tracking vehicle fuel consumption and expenses. Monitor your refueling history, analyze fuel efficiency, and manage your vehicle's fuel-related data with Firebase cloud sync.

## Features

- **Track Fuel Entries**: Log each refueling with details including:
  - Date and time
  - Kilometer reading
  - Total price (EGP)
  - Price per liter
  - Automatic calculation of liters filled

- **Fuel Consumption Analytics**:
  - Kilometers per liter (km/L)
  - Liters per 100 kilometers
  - Kilometers driven since last refill
  - Days between refills

- **Summary Statistics**: View comprehensive fuel consumption data across different time periods:
  - Custom date ranges
  - Monthly summaries
  - Overall statistics

- **Data Management**:
  - Add, edit, and delete fuel entries
  - Swipe-to-delete functionality
  - Firebase Realtime Database integration for cloud sync
  - Local persistence with SharedPreferences

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **Firebase**:
  - Firebase Core
  - Firebase Realtime Database
- **SharedPreferences**: Local data persistence

## Getting Started

### Prerequisites

- Flutter SDK (>=3.9.0)
- Dart SDK
- Firebase account and project setup

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/fuel-tracker.git
   cd fuel-tracker
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Ensure Firebase is properly configured in `firebase_options.dart`

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── models/
│   ├── fuel_entry.dart                 # Fuel entry data model
│   └── fuel_summary.dart               # Summary statistics model
├── providers/
│   └── fuel_provider.dart              # State management
├── screens/
│   ├── main_navigation_screen.dart     # Bottom navigation
│   ├── home_screen.dart                # Dashboard
│   ├── add_fuel_entry_screen.dart      # Add new entry
│   ├── edit_fuel_entry_screen.dart     # Edit existing entry
│   ├── logs_screen.dart                # Entry history
│   └── summary_screen.dart             # Statistics view
├── services/
│   └── firebase_service.dart           # Firebase operations
├── utils/
│   └── date_range.dart                 # Date utilities
└── widgets/
    └── simple_swipe_card.dart          # Swipeable card widget
```

## Usage

1. **Add Fuel Entry**: Tap the "+" button to log a new refueling
2. **View Logs**: Browse your refueling history with detailed metrics
3. **Check Summary**: Analyze your fuel consumption patterns over time
4. **Edit/Delete**: Swipe left on any entry to delete, or tap to edit

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

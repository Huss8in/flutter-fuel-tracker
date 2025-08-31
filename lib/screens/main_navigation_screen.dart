import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';
import '../utils/date_range.dart';
import 'summary_screen.dart';
import 'logs_screen.dart';
import 'add_fuel_entry_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _isAscending = false;

  final List<Widget> _screens = [
    const SummaryScreen(),
    const LogsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 350;
    final isSmallScreen = screenWidth < 400;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppleStyleAppBar(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildAppleStyleBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddFuelEntryScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        mini: isVerySmallScreen, // Use mini FAB for very small screens
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppleStyleAppBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: isSmallScreen ? 90 : 100,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
        ),
      ),
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top line - App Logo and Name (centered)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor.withValues(alpha: 0.15),
                        Theme.of(context).primaryColor.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_gas_station,
                    size: isSmallScreen ? 22 : 26,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 12),
                Text(
                  'Fuel Tracker',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isSmallScreen ? 8 : 10),
            
            // Bottom line - Date Filter (left) and Car Info + Settings (right)
            Row(
              children: [
                // Left side - Date Filter
                Expanded(
                  child: Row(
                    children: [
                      _buildAppleDateFilter(),
                    ],
                  ),
                ),
                
                // Right side - Car Info and Settings
                Row(
                  children: [
                    // Car Info Button
                    _buildAppleIconButton(
                      icon: Icons.directions_car_outlined,
                      onTap: () => _showCarInfoDialog(),
                    ),
                    
                    SizedBox(width: isSmallScreen ? 8 : 10),
                    
                    // Settings Button
                    _buildAppleIconButton(
                      icon: Icons.settings_outlined,
                      onTap: () => _showSettingsDialog(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    
    return Container(
      width: isSmallScreen ? 36 : 40,
      height: isSmallScreen ? 36 : 40,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleDateFilter() {
    return Consumer<FuelProvider>(
      builder: (context, fuelProvider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;
        
        return GestureDetector(
          onTap: () {
            if (fuelProvider.selectedDateRange == DateRange.custom) {
              _showAppleStyleDateRangeDialog(context, fuelProvider);
            } else {
              _showDateRangeMenu(context, fuelProvider);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  Theme.of(context).primaryColor.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: isSmallScreen ? 14 : 16,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: isSmallScreen ? 4 : 6),
                Flexible(
                  child: Text(
                    fuelProvider.selectedDateRange.label,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 2 : 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: isSmallScreen ? 14 : 16,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    bool isDarkMode = false; // TODO: Get from provider
    String selectedLanguage = 'English'; // TODO: Get from provider
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey.withValues(alpha: 0.15),
                      Colors.grey.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dark Mode Setting - iPhone Style
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.08),
                    width: 0.5,
                  ),
                ),
                child: _buildIPhoneStyleSettingTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: Colors.purple,
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark themes',
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: Switch.adaptive(
                      value: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isDarkMode = value;
                        });
                        // TODO: Update theme in provider
                      },
                      activeColor: Colors.purple,
                      activeTrackColor: Colors.purple.withValues(alpha: 0.3),
                      inactiveThumbColor: Colors.grey[400],
                      inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  isFirst: true,
                  isLast: true,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Language Setting - iPhone Style
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.08),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildIPhoneStyleSettingTile(
                      icon: Icons.language_outlined,
                      iconColor: Colors.blue,
                      title: 'Language',
                      subtitle: 'Choose your preferred language',
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onTap: () => _showLanguageSelector(context, selectedLanguage, (newLang) {
                        setState(() {
                          selectedLanguage = newLang;
                        });
                      }),
                      isFirst: true,
                      isLast: false,
                    ),
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.only(left: 64),
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    _buildIPhoneStyleSettingTile(
                      icon: Icons.translate_outlined,
                      iconColor: Colors.green,
                      title: 'Current Language',
                      subtitle: selectedLanguage,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedLanguage == 'English' ? 'EN' : 'عر',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                      isFirst: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.grey.withValues(alpha: 0.05),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCarInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withValues(alpha: 0.15),
                    Colors.blue.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Car Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarInfoItem('Model', 'Not Set', Icons.directions_car_outlined),
            const SizedBox(height: 12),
            _buildCarInfoItem('Year', 'Not Set', Icons.calendar_today_outlined),
            const SizedBox(height: 12),
            _buildCarInfoItem('Engine', 'Not Set', Icons.settings_outlined),
            const SizedBox(height: 12),
            _buildCarInfoItem('Tank Size', 'Not Set', Icons.local_gas_station_outlined),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Close',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to car info edit screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Edit Info',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDateRangeMenu(BuildContext context, FuelProvider provider) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(50, 70, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      items: DateRange.values.map((range) {
        return PopupMenuItem<DateRange>(
          value: range,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  range == provider.selectedDateRange
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: range == provider.selectedDateRange
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400],
                ),
                const SizedBox(width: 12),
                Text(
                  range.label,
                  style: TextStyle(
                    fontWeight: range == provider.selectedDateRange
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: range == provider.selectedDateRange
                        ? Theme.of(context).primaryColor
                        : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).then((selectedRange) {
      if (selectedRange != null) {
        if (selectedRange == DateRange.custom) {
          _showAppleStyleDateRangeDialog(context, provider);
        } else {
          provider.setDateRange(selectedRange);
        }
      }
    });
  }


  Widget _buildAppleStyleBottomNav() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 350;
    final isSmallScreen = screenWidth < 400;
    
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: isVerySmallScreen ? 60 : isSmallScreen ? 65 : 70,
          minHeight: isVerySmallScreen ? 55 : 60,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[500],
        selectedFontSize: isVerySmallScreen ? 8 : isSmallScreen ? 9 : 12,
        unselectedFontSize: isVerySmallScreen ? 8 : isSmallScreen ? 9 : 12,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: isVerySmallScreen ? 0 : isSmallScreen ? -0.1 : -0.2,
          fontSize: isVerySmallScreen ? 8 : isSmallScreen ? 9 : 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: isVerySmallScreen ? 8 : isSmallScreen ? 9 : 12,
          letterSpacing: isVerySmallScreen ? 0 : isSmallScreen ? -0.1 : 0,
        ),
        selectedIconTheme: IconThemeData(
          size: isVerySmallScreen ? 18 : isSmallScreen ? 20 : 24,
        ),
        unselectedIconTheme: IconThemeData(
          size: isVerySmallScreen ? 18 : isSmallScreen ? 20 : 24,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: MediaQuery.of(context).size.width < 350 
                ? 'Home' 
                : MediaQuery.of(context).size.width < 400 
                  ? 'Summary' 
                  : 'Summary',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Logs',
          ),
        ],
        ),
      ),
    );
  }

  void _showAppleStyleDateRangeDialog(BuildContext context, FuelProvider provider) {
    // Get all available dates from entries
    final allDates = provider.entries.map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toSet().toList()
      ..sort();
    
    if (allDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No fuel entries available'),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final earliestDate = allDates.first;
    final latestDate = allDates.last;
    
    DateTime startDate = provider.customStartDate ?? earliestDate;
    DateTime endDate = provider.customEndDate ?? latestDate;

    // Ensure dates are within available range
    startDate = startDate.isBefore(earliestDate) ? earliestDate : startDate;
    endDate = endDate.isAfter(latestDate) ? latestDate : endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.date_range,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Select Date Range',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clickable Date Tiles - Enhanced Design
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.1),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'FROM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                            letterSpacing: 0.5,
                          ),
                        ),
                        subtitle: Text(
                          '${startDate.day}/${startDate.month}/${startDate.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: -0.2,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_calendar,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: earliestDate,
                            lastDate: endDate.subtract(const Duration(days: 1)),
                          );
                          if (date != null) {
                            setState(() {
                              startDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.stop,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'TO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                            letterSpacing: 0.5,
                          ),
                        ),
                        subtitle: Text(
                          '${endDate.day}/${endDate.month}/${endDate.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: -0.2,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_calendar,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate.add(const Duration(days: 1)),
                            lastDate: latestDate,
                          );
                          if (date != null) {
                            setState(() {
                              endDate = date;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Range Slider Only
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: Theme.of(context).primaryColor,
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
                  thumbColor: Colors.white,
                  overlayColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                    elevation: 3,
                    pressedElevation: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 12,
                    elevation: 3,
                    pressedElevation: 6,
                  ),
                  rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                ),
                child: RangeSlider(
                  values: RangeValues(
                    startDate.difference(earliestDate).inDays.toDouble(),
                    endDate.difference(earliestDate).inDays.toDouble(),
                  ),
                  max: latestDate.difference(earliestDate).inDays.toDouble(),
                  divisions: latestDate.difference(earliestDate).inDays > 0 ? latestDate.difference(earliestDate).inDays : 1,
                  labels: RangeLabels(
                    '${startDate.day}/${startDate.month}',
                    '${endDate.day}/${endDate.month}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      startDate = earliestDate.add(Duration(days: values.start.round()));
                      endDate = earliestDate.add(Duration(days: values.end.round()));
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Enhanced Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.08),
                      Theme.of(context).primaryColor.withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.insights,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Range',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${endDate.difference(startDate).inDays + 1} days • ${_getEntriesInRange(provider.entries, startDate, endDate)} entries',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setCustomDateRange(startDate, endDate);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerBIDateSelector(String label, DateTime date, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        _getWeekdayName(date.weekday),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    return weekdays[weekday - 1];
  }

  Widget _buildDateChip(String label, DateTime date, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerBIRangeSlider({
    required DateTime earliestDate,
    required DateTime latestDate,
    required DateTime startDate,
    required DateTime endDate,
    required Function(DateTime, DateTime) onRangeChanged,
  }) {
    final totalDays = latestDate.difference(earliestDate).inDays;
    final startDays = startDate.difference(earliestDate).inDays;
    final endDays = endDate.difference(earliestDate).inDays;

    return Column(
      children: [
        // Timeline visualization
        Container(
          height: 60,
          child: CustomPaint(
            size: Size(double.infinity, 60),
            painter: TimelineSliderPainter(
              totalDays: totalDays,
              startDays: startDays,
              endDays: endDays,
              selectedColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
        
        // Range Slider
        RangeSlider(
          values: RangeValues(
            startDays.toDouble(),
            endDays.toDouble(),
          ),
          max: totalDays.toDouble(),
          divisions: totalDays > 0 ? totalDays : 1,
          labels: RangeLabels(
            '${startDate.day}/${startDate.month}',
            '${endDate.day}/${endDate.month}',
          ),
          onChanged: (RangeValues values) {
            final newStartDate = earliestDate.add(Duration(days: values.start.round()));
            final newEndDate = earliestDate.add(Duration(days: values.end.round()));
            onRangeChanged(newStartDate, newEndDate);
          },
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Colors.grey.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildTimelineIndicators(DateTime earliest, DateTime latest) {
    final months = <DateTime>[];
    var current = DateTime(earliest.year, earliest.month, 1);
    final end = DateTime(latest.year, latest.month + 1, 1);
    
    while (current.isBefore(end)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }

    return Container(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: months.take(5).map((month) {
          return Column(
            children: [
              Container(
                width: 2,
                height: 8,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 4),
              Text(
                '${month.month}/${month.year}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  int _getEntriesInRange(List entries, DateTime start, DateTime end) {
    return entries.where((entry) {
      return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
             entry.date.isBefore(end.add(const Duration(days: 1)));
    }).length;
  }

  Widget _buildDateTile(String label, DateTime date, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          '$label: ${date.day}/${date.month}/${date.year}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.calendar_today_outlined,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildIPhoneStyleSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isFirst,
    required bool isLast,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirst ? 16 : 0),
          bottom: Radius.circular(isLast ? 16 : 0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor.withValues(alpha: 0.2),
                      iconColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, String currentLanguage, Function(String) onLanguageChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withValues(alpha: 0.15),
                    Colors.blue.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.language,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              'English',
              'English',
              '🇺🇸',
              currentLanguage == 'English',
              () {
                onLanguageChanged('English');
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              'العربية',
              'Arabic',
              '🇸🇦',
              currentLanguage == 'Arabic',
              () {
                onLanguageChanged('Arabic');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String name, String code, String flag, bool isSelected, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.blue[700] : Colors.grey[800],
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue[600],
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimelineSliderPainter extends CustomPainter {
  final int totalDays;
  final int startDays;
  final int endDays;
  final Color selectedColor;

  TimelineSliderPainter({
    required this.totalDays,
    required this.startDays,
    required this.endDays,
    required this.selectedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final trackY = size.height / 2;
    final trackPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Draw background track
    canvas.drawLine(
      Offset(0, trackY),
      Offset(size.width, trackY),
      trackPaint,
    );

    // Draw selected range
    if (totalDays > 0) {
      final startX = (startDays / totalDays) * size.width;
      final endX = (endDays / totalDays) * size.width;
      
      // Draw selected range line
      final selectedPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            selectedColor.withValues(alpha: 0.8),
            selectedColor,
            selectedColor.withValues(alpha: 0.8),
          ],
        ).createShader(Rect.fromLTWH(startX, trackY - 4, endX - startX, 8))
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, trackY),
        Offset(endX, trackY),
        selectedPaint,
      );

      // Draw handle circles
      final handlePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = selectedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      // Start handle
      canvas.drawCircle(Offset(startX, trackY), 12, handlePaint);
      canvas.drawCircle(Offset(startX, trackY), 12, borderPaint);
      
      // End handle
      canvas.drawCircle(Offset(endX, trackY), 12, handlePaint);
      canvas.drawCircle(Offset(endX, trackY), 12, borderPaint);

      // Draw small inner circles
      final innerPaint = Paint()
        ..color = selectedColor
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(Offset(startX, trackY), 4, innerPaint);
      canvas.drawCircle(Offset(endX, trackY), 4, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


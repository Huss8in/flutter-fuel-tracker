import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../providers/car_provider.dart';
import '../models/car.dart';

class AddCarScreen extends StatefulWidget {
  final bool isOnboarding;

  const AddCarScreen({super.key, this.isOnboarding = false});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _registrationController = TextEditingController();
  final _mileageController = TextEditingController();

  String _selectedFuelType = 'Petrol';
  bool _isLoading = false;

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Hybrid', 'EV'];

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _registrationController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final carProvider = Provider.of<CarProvider>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      final newCar = Car(
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        fuelType: _selectedFuelType,
        registrationNumber: _registrationController.text.trim(),
        currentMileage: double.parse(_mileageController.text.trim()),
      );

      await carProvider.addCar(newCar);

      if (!mounted) return;

      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: const Text('Car Added Successfully'),
        description: Text(
          '${_makeController.text} ${_modelController.text} has been added to your garage',
        ),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topCenter,
      );

      if (widget.isOnboarding) {
        // Navigate to home screen after onboarding
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Just go back if adding from settings/garage
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: const Text('Error Adding Car'),
        description: Text(e.toString()),
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.topCenter,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOnboarding ? 'Add Your First Car' : 'Add Car'),
        automaticallyImplyLeading: !widget.isOnboarding,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isOnboarding) ...[
                  Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Fuel Tracker!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s start by adding your first car',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],

                // Make
                _buildTextField(
                  controller: _makeController,
                  label: 'Maker',
                  hint: 'e.g., Toyota, Ford, Honda',
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter car make';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Model
                _buildTextField(
                  controller: _modelController,
                  label: 'Model',
                  hint: 'e.g., Corolla, Mustang, Civic',
                  icon: Icons.directions_car,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter car model';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Year
                _buildTextField(
                  controller: _yearController,
                  label: 'Year',
                  hint: 'e.g., 2020',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter year';
                    }
                    final year = int.tryParse(value);
                    if (year == null) {
                      return 'Please enter a valid year';
                    }
                    final currentYear = DateTime.now().year;
                    if (year < 1900 || year > currentYear + 1) {
                      return 'Year must be between 1900 and ${currentYear + 1}';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Fuel Type Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedFuelType,
                    decoration: InputDecoration(
                      labelText: 'Fuel Type',
                      prefixIcon: Icon(
                        Icons.local_gas_station,
                        color: Theme.of(context).primaryColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: _fuelTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedFuelType = newValue;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Registration Number
                _buildTextField(
                  controller: _registrationController,
                  label: 'Registration Number',
                  hint: 'e.g., ABC-123',
                  icon: Icons.confirmation_number,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter registration number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Current Mileage
                _buildTextField(
                  controller: _mileageController,
                  label: 'Current Mileage (km)',
                  hint: 'e.g., 50000',
                  icon: Icons.speed,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter current mileage';
                    }
                    final mileage = double.tryParse(value);
                    if (mileage == null || mileage < 0) {
                      return 'Please enter a valid mileage';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.isOnboarding ? 'Get Started' : 'Add Car',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                if (widget.isOnboarding) ...[
                  const SizedBox(height: 16),
                  Text(
                    'You can add more cars later from settings',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
      ),
    );
  }
}

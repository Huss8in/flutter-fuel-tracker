import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_provider.dart';

class AddFuelEntryScreen extends StatefulWidget {
  const AddFuelEntryScreen({super.key});

  @override
  State<AddFuelEntryScreen> createState() => _AddFuelEntryScreenState();
}

class _AddFuelEntryScreenState extends State<AddFuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kilometerController = TextEditingController();
  final _priceController = TextEditingController();
  final _literPriceController = TextEditingController();
  final _kilometerFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  
  DateTime _selectedDate = DateTime.now();
  double _calculatedLiters = 0;
  int _calculatedKmDriven = 0;
  double _calculatedFuelConsumption = 0;
  double _calculatedLitersPer100Km = 0;
  int _calculatedDaysSince = 0;

  @override
  void initState() {
    super.initState();
    final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
    _literPriceController.text = fuelProvider.lastLiterPrice.toStringAsFixed(2);
    _updateCalculations();
  }

  void _updateCalculations() {
    final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
    final previousEntry = fuelProvider.entries.isNotEmpty ? fuelProvider.entries.last : null;
    
    final kilometer = int.tryParse(_kilometerController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final literPrice = double.tryParse(_literPriceController.text) ?? 1;
    
    setState(() {
      _calculatedLiters = literPrice > 0 ? price / literPrice : 0;
      
      if (previousEntry != null && kilometer > 0) {
        _calculatedKmDriven = kilometer - previousEntry.kilometerReading;
        _calculatedFuelConsumption = _calculatedLiters > 0 && _calculatedKmDriven > 0 
            ? _calculatedKmDriven / _calculatedLiters : 0;
        _calculatedLitersPer100Km = _calculatedKmDriven > 0 && _calculatedLiters > 0
            ? (100 * _calculatedLiters) / _calculatedKmDriven : 0;
        _calculatedDaysSince = _selectedDate.difference(previousEntry.date).inDays;
      } else {
        _calculatedKmDriven = 0;
        _calculatedFuelConsumption = 0;
        _calculatedLitersPer100Km = 0;
        _calculatedDaysSince = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('⛽ Add Fuel Entry'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('📅 Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                    _updateCalculations();
                  }
                },
              ),
              // Show last kilometer reading
              Consumer<FuelProvider>(
                builder: (context, fuelProvider, child) {
                  if (fuelProvider.entries.isNotEmpty) {
                    final lastEntry = fuelProvider.entries.last;
                    return Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Last entry: ${lastEntry.kilometerReading} km on ${lastEntry.date.day}/${lastEntry.date.month}/${lastEntry.date.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox(height: 16);
                },
              ),
              TextFormField(
                controller: _kilometerController,
                focusNode: _kilometerFocusNode,
                decoration: const InputDecoration(
                  labelText: '🏁 Kilometer Reading',
                  hintText: 'Enter current odometer reading',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter kilometer reading';
                  if (int.tryParse(value!) == null) return 'Please enter a valid number';
                  return null;
                },
                onChanged: (value) => _updateCalculations(),
                onFieldSubmitted: (value) {
                  // When user presses OK/Enter on numpad, focus on price field
                  _priceFocusNode.requestFocus();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                focusNode: _priceFocusNode,
                decoration: const InputDecoration(
                  labelText: '💲 Price (EGP)',
                  hintText: 'Enter total price paid',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter price';
                  if (double.tryParse(value!) == null) return 'Please enter a valid number';
                  return null;
                },
                onChanged: (value) => _updateCalculations(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _literPriceController,
                decoration: const InputDecoration(
                  labelText: '💰 Liter Price (EGP/L)',
                  hintText: 'Price per liter',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter liter price';
                  if (double.tryParse(value!) == null) return 'Please enter a valid number';
                  return null;
                },
                onChanged: (value) => _updateCalculations(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Calculated Values:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('⛽ Liters: ${_calculatedLiters.toStringAsFixed(2)} L'),
                      const SizedBox(height: 8),
                      if (_calculatedKmDriven > 0) ...[
                        Text('🚗 Kilometers Driven: $_calculatedKmDriven km'),
                        const SizedBox(height: 8),
                        Text('⛽ Fuel Consumption: ${_calculatedFuelConsumption.toStringAsFixed(2)} km/L'),
                        const SizedBox(height: 8),
                        Text('🚗⛽ L/100km: ${_calculatedLitersPer100Km.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        Text('📅 Days since last refill: $_calculatedDaysSince days'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
                      fuelProvider.addEntry(
                        date: _selectedDate,
                        kilometerReading: int.parse(_kilometerController.text),
                        priceEGP: double.parse(_priceController.text),
                        literPriceEGP: double.parse(_literPriceController.text),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Add Entry', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _kilometerController.dispose();
    _priceController.dispose();
    _literPriceController.dispose();
    _kilometerFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }
}
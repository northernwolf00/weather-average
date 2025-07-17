// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/weather_bloc.dart';
import '../blocs/weather_event.dart';

import '../models/city_model.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  CityType _selectedType = CityType.medium;
  Season _selectedSeason = Season.summer;

  final Map<String, TextEditingController> _monthControllers = {
    for (var month in [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ])
      month: TextEditingController(),
  };

  final Map<Season, List<String>> _seasonMonths = {
    Season.winter: ['December', 'January', 'February'],
    Season.spring: ['March', 'April', 'May'],
    Season.summer: ['June', 'July', 'August'],
    Season.autumn: ['September', 'October', 'November'],
  };

  void _saveCity() {
    try {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('City name cannot be empty')));
        return;
      }

      final existingCities = context.read<WeatherBloc>().state.cities;
      final duplicate = existingCities.any(
        (city) =>
            city.name.toLowerCase() == name.toLowerCase() &&
            city.season == _selectedSeason,
      );

      if (duplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'A city with the same name and season already exists',
            ),
          ),
        );
        return;
      }

      final temps = <String, double>{};

      for (String month in _seasonMonths[_selectedSeason]!) {
        temps[month] =
            double.tryParse(_monthControllers[month]?.text ?? '') ?? 0.0;
      }

      final city = City(
        name: name,
        type: _selectedType,
        season: _selectedSeason,
        monthlyTemperatures: temps,
      );

      context.read<WeatherBloc>().add(AddCity(city));
      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error while adding city')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add / Edit City',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'City Name',
                border: inputBorder,
                focusedBorder: inputBorder.copyWith(
                  borderSide: BorderSide(color: primaryColor),
                ),
                prefixIcon: Icon(Icons.location_city, color: primaryColor),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // City Type Dropdown
            Text(
              'City Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CityType>(
                  value: _selectedType,
                  icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                  items:
                      CityType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type.name[0].toUpperCase() +
                                    type.name.substring(1),
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Season Dropdown
            Text(
              'Season',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Season>(
                  value: _selectedSeason,
                  icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSeason = value;
                      });
                    }
                  },
                  items:
                      Season.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s.name[0].toUpperCase() + s.name.substring(1),
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            SizedBox(height: 24),

            Text(
              'Temperatures for ${_selectedSeason.name.toUpperCase()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 12),

            ..._seasonMonths[_selectedSeason]!.map(
              (month) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: TextField(
                  controller: _monthControllers[month],
                  decoration: InputDecoration(
                    labelText: 'Temperature for $month (°C)',
                    border: inputBorder,
                    focusedBorder: inputBorder.copyWith(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    prefixIcon: Icon(
                      Icons.thermostat_outlined,
                      color: primaryColor,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveCity,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: primaryColor,
                  elevation: 4,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

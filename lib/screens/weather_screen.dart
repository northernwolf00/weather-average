import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/weather_bloc.dart';
import '../blocs/weather_event.dart';
import '../blocs/weather_state.dart';
import '../models/city_model.dart';
import 'settings_screen.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final Map<Season, List<String>> seasonMonths = {
    Season.winter: ['December', 'January', 'February'],
    Season.spring: ['March', 'April', 'May'],
    Season.summer: ['June', 'July', 'August'],
    Season.autumn: ['September', 'October', 'November'],
  };

  @override
  void initState() {
    super.initState();

    final bloc = context.read<WeatherBloc>();
    final currentState = bloc.state;
    if (currentState.selectedSeason == null) {
      bloc.add(SelectCityAndSeason("", Season.winter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final secondaryColor = Theme.of(
      context,
    ).colorScheme.secondary.withOpacity(0.1);
    final primaryColorDark = Theme.of(context).primaryColorDark;

    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        final cities = state.cities;
        final selectedCity = state.selectedCity;
        final selectedSeason = state.selectedSeason ?? Season.winter;

        final citiesForSeason =
            cities.where((c) => c.season == selectedSeason).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Weather',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            backgroundColor: primaryColor,
            elevation: 2,
            actions: [
              IconButton(
                icon: Icon(Icons.settings),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsScreen()),
                    ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Season',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryColorDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Season>(
                        isExpanded: true,
                        value: selectedSeason,
                        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                        onChanged: (season) {
                          if (season != null) {
                            context.read<WeatherBloc>().add(
                              SelectCityAndSeason("", season),
                            );
                          }
                        },
                        items:
                            Season.values
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s.name[0].toUpperCase() +
                                          s.name.substring(1),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  if (citiesForSeason.isNotEmpty) ...[
                    Text(
                      'Select City',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primaryColorDark,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value:
                              citiesForSeason.any(
                                    (city) => city.name == selectedCity,
                                  )
                                  ? selectedCity
                                  : null,
                          hint: Text(
                            'Select City',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: primaryColor,
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<WeatherBloc>().add(
                                SelectCityAndSeason(value, selectedSeason),
                              );
                            }
                          },
                          items:
                              citiesForSeason
                                  .map(
                                    (city) => DropdownMenuItem<String>(
                                      value: city.name,
                                      child: Text(
                                        city.name,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(height: 24),
                    Center(
                      child: Text(
                        'No cities yet for ${selectedSeason.name[0].toUpperCase() + selectedSeason.name.substring(1)} season.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 32),
                  if (state.selectedCityData != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        child: Builder(
                          builder: (_) {
                            final city = state.selectedCityData!;
                            final months = seasonMonths[city.season]!;
                            final temps = months
                                .map(
                                  (m) =>
                                      '$m: ${city.monthlyTemperatures[m]?.toStringAsFixed(1) ?? '-'}°C',
                                )
                                .join('\n');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColorDark,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Type: ${city.typeName}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Season: ${city.season.name[0].toUpperCase() + city.season.name.substring(1)}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Divider(height: 24, thickness: 1),
                                Text(
                                  'Monthly Temperatures:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  temps,
                                  style: TextStyle(fontSize: 16, height: 1.4),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Average Temperature: ${city.getAverageTemperature().toStringAsFixed(1)}°C',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColorDark,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

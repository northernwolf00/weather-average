import '../models/city_model.dart';


class WeatherState {
  final List<City> cities;
  final String? selectedCity;
  final Season? selectedSeason;

  WeatherState({
    required this.cities,
    this.selectedCity,
    this.selectedSeason,
  });

  WeatherState copyWith({
    List<City>? cities,
    String? selectedCity,
    Season? selectedSeason,
  }) {
    return WeatherState(
      cities: cities ?? this.cities,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedSeason: selectedSeason ?? this.selectedSeason,
    );
  }

  City? get selectedCityData {
    try {
      return cities.firstWhere(
        (city) => city.name == selectedCity && city.season == selectedSeason,
      );
    } catch (_) {
      return null;
    }
  }
}


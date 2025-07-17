import '../models/city_model.dart';


abstract class WeatherEvent {}

class AddCity extends WeatherEvent {
  final City city;
  AddCity(this.city);
}

class SelectCityAndSeason extends WeatherEvent {
  final String cityName;
  final Season season;
  SelectCityAndSeason(this.cityName, this.season);
}
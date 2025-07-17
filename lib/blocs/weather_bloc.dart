import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/city_model.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherState(cities: [])) {
    on<AddCity>((event, emit) {
      final updated = List<City>.from(state.cities)
        ..removeWhere((c) => c.name == event.city.name && c.season == event.city.season)
        ..add(event.city);
      emit(state.copyWith(cities: updated));
    });

    on<SelectCityAndSeason>((event, emit) {
      emit(state.copyWith(
        selectedCity: event.cityName,
        selectedSeason: event.season,
      ));
    });
  }
}


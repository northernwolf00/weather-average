enum CityType { small, medium, large }
enum Season { winter, spring, summer, autumn }

class City {
  final String name;
  final CityType type;
  final Season season;
  final Map<String, double> monthlyTemperatures;

  City({
    required this.name,
    required this.type,
    required this.season,
    required this.monthlyTemperatures,
  });

  double getAverageTemperature() {
    final months = _monthsBySeason[season]!;
    final temps = months.map((m) => monthlyTemperatures[m] ?? 0).toList();
    return temps.reduce((a, b) => a + b) / temps.length;
  }

  static const Map<Season, List<String>> _monthsBySeason = {
    Season.winter: ['December', 'January', 'February'],
    Season.spring: ['March', 'April', 'May'],
    Season.summer: ['June', 'July', 'August'],
    Season.autumn: ['September', 'October', 'November'],
  };

  String get typeName => type.name;
}

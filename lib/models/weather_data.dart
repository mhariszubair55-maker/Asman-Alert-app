class WeatherData {
  final String location;
  final double latitude;
  final double longitude;
  final double temperature;
  final double feelsLike;
  final double high;
  final double low;
  final int rainChance;
  final double precipitationMm;
  final double windKmh;
  final int windDirection;
  final int humidity;
  final int cloudCover;
  final String condition;
  final DateTime updatedAt;
  final List<HourlyWeather> nextHours;

  const WeatherData({
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.feelsLike,
    required this.high,
    required this.low,
    required this.rainChance,
    required this.precipitationMm,
    required this.windKmh,
    required this.windDirection,
    required this.humidity,
    required this.cloudCover,
    required this.condition,
    required this.updatedAt,
    required this.nextHours,
  });
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int rainChance;
  final double precipitationMm;
  final int weatherCode;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.rainChance,
    required this.precipitationMm,
    required this.weatherCode,
  });
}

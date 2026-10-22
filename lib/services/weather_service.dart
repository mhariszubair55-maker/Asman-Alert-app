import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const _timeout = Duration(seconds: 18);

  // Open-Meteo provides forecast data without an API key for eligible use.
  // Check its current terms and attribution requirements before public/commercial release.
  Future<WeatherData> getWeather({
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,weather_code,cloud_cover,wind_speed_10m,wind_direction_10m',
      'hourly': 'temperature_2m,precipitation_probability,precipitation,weather_code',
      'daily': 'temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum',
      'forecast_days': '2',
      'timezone': 'Asia/Karachi',
    });

    final response = await http.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('موسم کا ڈیٹا حاصل نہیں ہو سکا (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final times = (hourly['time'] as List).cast<String>();
    final temps = (hourly['temperature_2m'] as List).cast<num>();
    final probs = (hourly['precipitation_probability'] as List).cast<num>();
    final rain = (hourly['precipitation'] as List).cast<num>();
    final codes = (hourly['weather_code'] as List).cast<num>();

    final now = DateTime.parse(current['time'] as String);
    int startIndex = times.indexWhere((t) => !DateTime.parse(t).isBefore(now));
    if (startIndex < 0) startIndex = 0;
    final hours = <HourlyWeather>[];
    for (int i = startIndex; i < times.length && hours.length < 12; i++) {
      hours.add(HourlyWeather(
        time: DateTime.parse(times[i]),
        temperature: temps[i].toDouble(),
        rainChance: probs[i].toInt(),
        precipitationMm: rain[i].toDouble(),
        weatherCode: codes[i].toInt(),
      ));
    }

    final dailyMax = (daily['temperature_2m_max'] as List).cast<num>();
    final dailyMin = (daily['temperature_2m_min'] as List).cast<num>();
    final dailyRainChance = (daily['precipitation_probability_max'] as List).cast<num>();
    final dailyRain = (daily['precipitation_sum'] as List).cast<num>();

    return WeatherData(
      location: location,
      latitude: latitude,
      longitude: longitude,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      high: dailyMax.first.toDouble(),
      low: dailyMin.first.toDouble(),
      rainChance: dailyRainChance.first.toInt(),
      precipitationMm: dailyRain.first.toDouble(),
      windKmh: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: (current['wind_direction_10m'] as num).toInt(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      cloudCover: (current['cloud_cover'] as num).toInt(),
      condition: weatherDescription((current['weather_code'] as num).toInt()),
      updatedAt: now,
      nextHours: hours,
    );
  }

  static String weatherDescription(int code) {
    if (code == 0) return 'صاف آسمان';
    if ([1, 2].contains(code)) return 'جزوی ابر آلود';
    if (code == 3) return 'ابر آلود';
    if ([45, 48].contains(code)) return 'دھند';
    if ([51, 53, 55, 56, 57].contains(code)) return 'ہلکی بوندا باندی';
    if ([61, 63, 65, 66, 67].contains(code)) return 'بارش';
    if ([71, 73, 75, 77].contains(code)) return 'برف باری';
    if ([80, 81, 82].contains(code)) return 'بارش کی بوچھاڑ';
    if ([85, 86].contains(code)) return 'برف کی بوچھاڑ';
    if ([95, 96, 99].contains(code)) return 'گرج چمک کا امکان';
    return 'موسم کی کیفیت دستیاب';
  }

  static String windDirectionText(int degrees) {
    const directions = ['شمال', 'شمال مشرق', 'مشرق', 'جنوب مشرق', 'جنوب', 'جنوب مغرب', 'مغرب', 'شمال مغرب'];
    return directions[((degrees % 360) / 45).round() % 8];
  }
}

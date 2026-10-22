import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

class DetailsScreen extends StatelessWidget {
  final WeatherData weather;
  const DetailsScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('موسم کی مزید تفصیل')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(color: const Color(0xFFE7F2FF), child: const Padding(padding: EdgeInsets.all(14), child: Text('یہ پیش گوئی کا ماڈل ڈیٹا ہے؛ موسمی حالات بدل سکتے ہیں۔ شدید موسم کے لیے سرکاری وارننگ دیکھیں۔'))),
        _tile(Icons.cloudy_snowing, 'آج بارش کا امکان', '${weather.rainChance}%'),
        _tile(Icons.water_drop, 'آج متوقع بارش', '${weather.precipitationMm.toStringAsFixed(1)} ملی میٹر'),
        _tile(Icons.thermostat, 'درجہ حرارت', '${weather.temperature.toStringAsFixed(1)}°C'),
        _tile(Icons.device_thermostat, 'محسوس ہونے والا درجہ حرارت', '${weather.feelsLike.toStringAsFixed(1)}°C'),
        _tile(Icons.arrow_upward, 'زیادہ سے زیادہ', '${weather.high.round()}°C'),
        _tile(Icons.arrow_downward, 'کم سے کم', '${weather.low.round()}°C'),
        _tile(Icons.air, 'ہوا کی رفتار', '${weather.windKmh.toStringAsFixed(1)} کلومیٹر فی گھنٹہ'),
        _tile(Icons.explore, 'ہوا کی سمت', WeatherService.windDirectionText(weather.windDirection)),
        _tile(Icons.water_drop_outlined, 'نمی', '${weather.humidity}%'),
        _tile(Icons.cloud_outlined, 'بادلوں کی مقدار', '${weather.cloudCover}%'),
        const SizedBox(height: 12),
        const Text('اگلے گھنٹوں کی پیش گوئی', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...weather.nextHours.map((h) => Card(child: ListTile(
          leading: const Icon(Icons.schedule, color: Color(0xFF124A8A)),
          title: Text('${h.time.hour.toString().padLeft(2, '0')}:${h.time.minute.toString().padLeft(2, '0')} • ${h.temperature.round()}°C'),
          subtitle: Text('بارش کا امکان ${h.rainChance}% • مقدار ${h.precipitationMm.toStringAsFixed(1)} ملی میٹر'),
          trailing: const Icon(Icons.cloud_outlined),
        ))),
      ]),
    );
  }

  Widget _tile(IconData icon, String title, String value) => Card(child: ListTile(
    leading: Icon(icon, color: const Color(0xFF124A8A)),
    title: Text(title),
    trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
  ));
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/weather_data.dart';
import '../services/weather_service.dart';
import 'details_screen.dart';
import 'flood_screen.dart';

final FlutterLocalNotificationsPlugin weatherNotifications =
    FlutterLocalNotificationsPlugin();

Future<void> initializeWeatherNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await weatherNotifications.initialize(settings);

  final androidPlugin = weatherNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.requestNotificationsPermission();
}

Future<void> showWeatherAlert(WeatherData weather) async {
  if (weather.rainChance < 60) return;

  const androidDetails = AndroidNotificationDetails(
    'weather_alerts',
    'موسمی الرٹس',
    channelDescription: 'بارش کے امکان سے متعلق اطلاعات',
    importance: Importance.high,
    priority: Priority.high,
  );

  await weatherNotifications.show(
    1001,
    'آسمان الرٹ: بارش کا امکان',
    '${weather.location} میں بارش کا امکان ${weather.rainChance}% ہے۔',
    const NotificationDetails(android: androidDetails),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = WeatherService();

  bool _loading = true;
  bool _gpsLoading = false;
  bool _alertsEnabled = true;
  String? _error;
  WeatherData? _weather;
  String _city = 'بہاولپور';

  static const _cities = <String, List<double>>{
    'بہاولپور': [29.3956, 71.6836],
    'احمدپور شرقیہ': [29.1431, 71.2577],
    'ملتان': [30.1575, 71.5249],
    'لاہور': [31.5204, 74.3587],
    'کراچی': [24.8607, 67.0011],
    'اسلام آباد': [33.6844, 73.0479],
    'فیصل آباد': [31.4504, 73.1350],
    'رحیم یار خان': [28.4212, 70.2989],
    'ڈیرہ غازی خان': [30.0561, 70.6348],
    'پشاور': [34.0151, 71.5249],
    'کوئٹہ': [30.1798, 66.9750],
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await initializeWeatherNotifications();
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
    }
    await _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final coords = _cities[_city]!;
      final data = await _service.getWeather(
        location: _city,
        latitude: coords[0],
        longitude: coords[1],
      );

      if (!mounted) return;
      setState(() {
        _weather = data;
        _loading = false;
      });

      if (_alertsEnabled) {
        try {
          await showWeatherAlert(data);
        } catch (e) {
          debugPrint('Weather notification failed: $e');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('AASMAN WEATHER ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _error = 'موسم کا ڈیٹا حاصل نہیں ہو سکا۔ انٹرنیٹ چیک کرکے دوبارہ کوشش کریں۔';
        _loading = false;
      });
    }
  }

  Future<void> _useGps() async {
    setState(() {
      _gpsLoading = true;
      _error = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('فون کی Location/GPS سیٹنگ آن کریں۔');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('موجودہ مقام کے لیے Location کی اجازت درکار ہے۔');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );

      final data = await _service.getWeather(
        location: 'میرا موجودہ مقام',
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _weather = data;
        _city = 'میرا موجودہ مقام';
        _loading = false;
      });

      if (_alertsEnabled) {
        await showWeatherAlert(data);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'GPS موسم حاصل نہیں ہوا: $e';
        _loading = false;
      });
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  Future<void> _selectCity(String city) async {
    setState(() => _city = city);
    await _loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    final w = _weather;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('آسمان الرٹ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('بارش اور موسم کی بروقت اطلاع',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadWeather,
            tooltip: 'تازہ کریں',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _openMenu,
            tooltip: 'مینو',
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              const Icon(Icons.location_on, color: Color(0xFF124A8A)),
              const SizedBox(width: 6),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _cities.containsKey(_city) ? _city : null,
                  hint: Text(_city),
                  underline: const SizedBox.shrink(),
                  items: _cities.keys.map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city, style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) _selectCity(value);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _gpsLoading ? null : _useGps,
              icon: _gpsLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
              label: const Text('میرے موجودہ مقام کا موسم'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('بارش کے نوٹیفکیشن'),
              subtitle: const Text(
                  'تازہ موسم چیک ہونے پر بارش کا امکان 60% یا زیادہ ہو تو اطلاع'),
              value: _alertsEnabled,
              onChanged: (v) => setState(() => _alertsEnabled = v),
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(children: [
                    const Icon(Icons.cloud_off, size: 42, color: Colors.orange),
                    const SizedBox(height: 10),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _loadWeather,
                      icon: const Icon(Icons.refresh),
                      label: const Text('دوبارہ کوشش کریں'),
                    ),
                  ]),
                ),
              )
            else if (w != null) ...[
              _statusCard(w),
              const SizedBox(height: 14),
              _rainCard(w),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _smallCard(
                  Icons.device_thermostat, 'درجہ حرارت',
                  '${w.temperature.round()}°C',
                  'محسوس ${w.feelsLike.round()}°C',
                  const Color(0xFFE56B25))),
                const SizedBox(width: 12),
                Expanded(child: _smallCard(
                  Icons.air, 'ہوا', '${w.windKmh.round()} km/h',
                  WeatherService.windDirectionText(w.windDirection),
                  const Color(0xFF159B68))),
              ]),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud, color: Color(0xFF124A8A)),
                  title: const Text('آسمان کی کیفیت'),
                  subtitle: Text(w.condition),
                  trailing: Text('${w.humidity}% نمی'),
                ),
              ),
              const SizedBox(height: 18),
              const Text('اگلے 7 دن کی پیش گوئی',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...w.sevenDayForecast.map((day) => Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month,
                      color: Color(0xFF124A8A)),
                  title: Text(
                    '${day.date.day}/${day.date.month}/${day.date.year}',
                  ),
                  subtitle: Text(
                    '${WeatherService.weatherDescription(day.weatherCode)}'
                    '\nبارش کا امکان ${day.rainChance}%'
                    ' • متوقع بارش ${day.precipitationMm.toStringAsFixed(1)} ملی میٹر',
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('↑ ${day.high.round()}°',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('↓ ${day.low.round()}°'),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailsScreen(weather: w)),
                ),
                icon: const Icon(Icons.expand_more),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('مزید تفصیل دیکھیں'),
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Text(
              'موسم کی پیش گوئی بدل سکتی ہے۔ ہنگامی صورتحال میں سرکاری وارننگ کو ترجیح دیں۔',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const Text(
              'موسمی ڈیٹا: Open-Meteo • سرکاری وارننگز کے لیے سیلاب کا صفحہ دیکھیں۔',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(WeatherData w) => Card(
    color: const Color(0xFF124A8A),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(children: [
        const Icon(Icons.wb_cloudy_outlined, color: Colors.white, size: 48),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('موجودہ موسم', style: TextStyle(color: Colors.white70)),
            Text(w.condition, style: const TextStyle(
              color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
            Text('زیادہ سے زیادہ ${w.high.round()}° • کم سے کم ${w.low.round()}°',
                style: const TextStyle(color: Colors.white)),
          ],
        )),
      ]),
    ),
  );

  Widget _rainCard(WeatherData w) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.cloudy_snowing,
              color: Color(0xFF1685D1), size: 40),
          const SizedBox(width: 12),
          const Expanded(child: Text('آج بارش کا امکان',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Text('${w.rainChance}%',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: w.rainChance.clamp(0, 100) / 100,
            minHeight: 9,
          ),
        ),
        const SizedBox(height: 10),
        Text('متوقع بارش: ${w.precipitationMm.toStringAsFixed(1)} ملی میٹر'),
      ]),
    ),
  );

  Widget _smallCard(
    IconData icon, String title, String value, String subtitle, Color color
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(fontSize: 12)),
      ]),
    ),
  );

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.water, color: Colors.blue),
            title: const Text('سیلاب کی صورتحال'),
            subtitle: const Text('سرکاری FFD معلومات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FloodScreen()));
            },
          ),
          const ListTile(
            leading: Icon(Icons.notifications_active_outlined),
            title: Text('موسمی الرٹس'),
            subtitle: Text('موسم تازہ کرنے پر بارش کی اطلاع'),
          ),
        ]),
      ),
    );
  }
}

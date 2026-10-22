import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import 'details_screen.dart';
import 'flood_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = WeatherService();
  bool _loading = true;
  String? _error;
  WeatherData? _weather;
  String _city = 'بہاولپور';

  // Initial city is Bahawalpur. GPS and city search can be added next.
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
    _loadWeather();
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'موسم کا تازہ ڈیٹا نہیں مل سکا۔ انٹرنیٹ چیک کرکے دوبارہ کوشش کریں۔';
        _loading = false;
      });
    }
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
            Text('بارش اور موسم کی بروقت اطلاع', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(onPressed: _loadWeather, tooltip: 'تازہ کریں', icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _openMenu, tooltip: 'مینو', icon: const Icon(Icons.menu)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF124A8A)),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _city,
                    underline: const SizedBox.shrink(),
                    items: _cities.keys.map((city) => DropdownMenuItem(value: city, child: Text(city, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _city = value);
                      _loadWeather();
                    },
                  ),
                ),
                const Chip(label: Text('لائیو ڈیٹا', style: TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact),
              ],
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(children: [
                    const Icon(Icons.cloud_off, size: 42, color: Colors.orange),
                    const SizedBox(height: 10),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(onPressed: _loadWeather, icon: const Icon(Icons.refresh), label: const Text('دوبارہ کوشش کریں')),
                  ]),
                ),
              )
            else if (w != null) ...[
              _statusCard(w),
              const SizedBox(height: 14),
              _rainCard(w),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _smallCard(Icons.device_thermostat, 'درجہ حرارت', '${w.temperature.round()}°C', 'محسوس ${w.feelsLike.round()}°C', const Color(0xFFE56B25))),
                const SizedBox(width: 12),
                Expanded(child: _smallCard(Icons.air, 'ہوا', '${w.windKmh.round()} km/h', WeatherService.windDirectionText(w.windDirection), const Color(0xFF159B68))),
              ]),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    const Icon(Icons.cloud, color: Color(0xFF124A8A), size: 38),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('آسمان کی کیفیت', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(w.condition),
                    ])),
                    Column(children: [const Icon(Icons.water_drop_outlined, color: Color(0xFF1685D1)), Text('${w.humidity}% نمی', style: const TextStyle(fontSize: 12))]),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Text('بادلوں کی مقدار: ${w.cloudCover}% • آج کی متوقع بارش: ${w.precipitationMm.toStringAsFixed(1)} ملی میٹر', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text('آخری اپ ڈیٹ: ${_formatTime(w.updatedAt)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(weather: w))),
                icon: const Icon(Icons.expand_more),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Text('مزید تفصیل دیکھیں', style: TextStyle(fontSize: 17))),
              ),
            ],
            const SizedBox(height: 12),
            const Text('موسم کی پیش گوئی بدل سکتی ہے۔ ہنگامی صورتحال میں سرکاری وارننگ کو ترجیح دیں۔', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 12),
            const Text('موسمی ڈیٹا: Open-Meteo • سرکاری وارننگز کے لیے مینو میں سیلاب کا صفحہ دیکھیں۔', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(WeatherData w) => Card(
    color: const Color(0xFF124A8A),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(children: [
        const Icon(Icons.wb_cloudy_outlined, color: Colors.white, size: 48),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('موجودہ موسم', style: TextStyle(color: Colors.white70)),
          Text(w.condition, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
          Text('زیادہ سے زیادہ ${w.high.round()}° • کم سے کم ${w.low.round()}°', style: const TextStyle(color: Colors.white)),
        ])),
      ]),
    ),
  );

  Widget _rainCard(WeatherData w) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.cloudy_snowing, color: Color(0xFF1685D1), size: 44),
          const SizedBox(width: 12),
          const Expanded(child: Text('آج بارش کا امکان', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Text('${w.rainChance}%', style: const TextStyle(fontSize: 29, fontWeight: FontWeight.bold, color: Color(0xFF124A8A))),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: w.rainChance / 100, minHeight: 9, backgroundColor: const Color(0xFFE5EDF5), color: const Color(0xFF1685D1))),
        const SizedBox(height: 10),
        Text('آج کی متوقع بارش: ${w.precipitationMm.toStringAsFixed(1)} ملی میٹر', style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _smallCard(IconData icon, String title, String value, String subtitle, Color color) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(fontSize: 12)),
      ]),
    ),
  );

  String _formatTime(DateTime d) {
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} $hour:$minute';
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.water, color: Colors.blue), title: const Text('سیلاب کی صورتحال'), subtitle: const Text('سرکاری FFD معلومات'), onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FloodScreen()));
        }),
        const ListTile(leading: Icon(Icons.notifications_active_outlined), title: Text('موسمی الرٹس'), subtitle: Text('پش نوٹیفکیشن ابھی شامل نہیں')),
        const ListTile(leading: Icon(Icons.settings_outlined), title: Text('ترتیبات'), subtitle: Text('مزید فیچرز بعد میں شامل ہوں گے')),
      ])),
    );
  }
}

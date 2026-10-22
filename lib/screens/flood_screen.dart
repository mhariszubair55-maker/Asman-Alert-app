import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FloodScreen extends StatelessWidget {
  const FloodScreen({super.key});

  static final Uri _dashboard = Uri.parse('https://ffd.pmd.gov.pk/flood-dashboard');
  static final Uri _warnings = Uri.parse('https://ffd.pmd.gov.pk/flood-ews');

  Future<void> _open(Uri uri, BuildContext context) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ویب سائٹ نہیں کھل سکی۔ انٹرنیٹ چیک کریں۔')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سیلاب کی صورتحال')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(color: const Color(0xFFFFF1D6), child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, color: Colors.deepOrange, size: 30),
            SizedBox(width: 12),
            Expanded(child: Text('سیلاب کے لیے صرف سرکاری معلومات استعمال کریں۔ اس ورژن میں سرکاری ڈیش بورڈ کھلتا ہے؛ دریا کی سطح ایپ کے اندر خودکار طور پر پڑھ کر نہیں دکھائی جاتی۔', style: TextStyle(height: 1.5))),
          ]),
        )),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => _open(_dashboard, context),
          icon: const Icon(Icons.open_in_browser),
          label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('سرکاری FFD سیلاب ڈیش بورڈ کھولیں')),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _open(_warnings, context),
          icon: const Icon(Icons.warning_amber_rounded),
          label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('سرکاری سیلابی وارننگز اور وضاحت')),
        ),
        const SizedBox(height: 20),
        const Text('اگلے مرحلے میں', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const ListTile(leading: Icon(Icons.water), title: Text('دریا اور بیراج کی تازہ سطح'), subtitle: Text('صرف قابلِ اعتماد اور باقاعدہ دستیاب ڈیٹا کے ساتھ')),
        const ListTile(leading: Icon(Icons.trending_up), title: Text('پانی بڑھنے یا کم ہونے کا رجحان')),
        const ListTile(leading: Icon(Icons.map_outlined), title: Text('متاثرہ علاقوں کا نقشہ')),
        const ListTile(leading: Icon(Icons.notifications_active), title: Text('سرکاری وارننگ کی بنیاد پر الرٹ')),
        const SizedBox(height: 12),
        const Text('ہنگامی صورتحال میں مقامی انتظامیہ، Rescue 1122 اور سرکاری ہدایات پر عمل کریں۔ ایپ کو واحد حفاظتی ذریعہ نہ سمجھیں.', style: TextStyle(fontWeight: FontWeight.w600, height: 1.5)),
      ]),
    );
  }
}

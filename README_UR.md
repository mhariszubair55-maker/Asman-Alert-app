# آسمان الرٹ — حقیقی موسم والے ابتدائی پروجیکٹ

## اس ورژن میں کیا حقیقی ہے؟
- Open-Meteo API سے موجودہ موسم اور پیش گوئی انٹرنیٹ کے ذریعے حاصل ہوتی ہے؛ API key کی ضرورت نہیں۔
- بہاولپور، احمدپور شرقیہ، ملتان، لاہور، کراچی، اسلام آباد، فیصل آباد، رحیم یار خان، ڈیرہ غازی خان، پشاور اور کوئٹہ میں سے شہر منتخب کیا جا سکتا ہے۔
- درجہ حرارت، محسوس ہونے والا درجہ حرارت، ہوا، سمت، نمی، بادل، بارش کا امکان اور اگلے 12 گھنٹوں کا ڈیٹا دکھایا جاتا ہے۔
- سیلاب والے صفحے سے پاکستان کے Flood Forecasting Division (PMD) کے سرکاری ڈیش بورڈ اور وارننگ پیج کھلتے ہیں۔

## ابھی کیا مکمل نہیں؟
- GPS سے خودکار موجودہ مقام
- حقیقی push notifications / پس منظر میں الرٹس
- سیلابی دریا کی سطح کو ایپ کے اندر خودکار طور پر پڑھ کر دکھانا
- نقشے/ریڈار کی تہیں
- Play Store کے لیے build، device testing اور release signing

سیلابی ڈیٹا کے لیے اس ورژن میں کوئی فرضی خطرے کی سطح نہیں دکھائی جاتی؛ سرکاری FFD ویب سائٹ کھولی جاتی ہے۔ حقیقی سیلابی feed کے لیے PMD/FFD کی باقاعدہ دستیاب API یا اجازت یافتہ data feed درکار ہوگی۔

## موبائل پر اہم بات
Acode کوڈ ایڈیٹر ہے؛ یہ خود Flutter ایپ compile/run نہیں کرتا۔ ZIP کو extract کرکے فائلیں دیکھی جا سکتی ہیں، مگر ایپ چلانے کے لیے Flutter SDK والا کمپیوٹر یا مناسب cloud development environment درکار ہے۔

## کمپیوٹر یا Flutter ماحول میں چلانا
1. Flutter SDK انسٹال کریں: https://flutter.dev
2. ZIP extract کریں۔
3. پروجیکٹ فولڈر میں terminal کھولیں۔
4. `flutter pub get`
5. `flutter run`

## ڈیٹا اور احتیاط
- Weather data: Open-Meteo Forecast API (`https://open-meteo.com/`)
- Official flood information: Pakistan Meteorological Department Flood Forecasting Division (`https://ffd.pmd.gov.pk/flood-dashboard`)
- سرکاری warnings کو ترجیح دیں۔ موسمی پیش گوئی بدل سکتی ہے۔
- عوامی یا تجارتی ریلیز سے پہلے Open-Meteo کی موجودہ شرائط، attribution اور استعمال کی حدود کی تصدیق کریں۔

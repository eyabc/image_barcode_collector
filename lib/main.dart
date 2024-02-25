import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_barcode_collector/views/home.dart';

import 'app.dart';

const Map<String, String> UNIT_ID = kReleaseMode
    ? {
  'ios': 'ca-app-pub-1302807400867776/3579352973',
  'android': 'ca-app-pub-1302807400867776/7575767293',
}
: {
  'ios': 'ca-app-pub-3940256099942544/2934735716',
  'android': 'ca-app-pub-3940256099942544/2934735716',
};

Future<void> main() async {

  // 앱의 endpoint, 변수 초기화
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await HomeRefresher.refresh();

  runApp(const App());
}



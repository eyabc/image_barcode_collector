import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_barcode_collector/views/home.dart';

import 'app.dart';

const Map<String, String> UNIT_ID = kReleaseMode
    ? {
  'ios': '[YOUR iOS AD UNIT ID]',
  'android': '[YOUR ANDROID AD UNIT ID]',
}
: {
  'ios': 'ca-app-pub-1302807400867776~4933292080',
  'android': 'ca-app-pub-1302807400867776~3496921486',
};


Future<void> main() async {

  // 앱의 endpoint, 변수 초기화
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  await HomeRefresher.refresh();

  runApp(const App());
}



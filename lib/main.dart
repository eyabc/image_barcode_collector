import 'package:flutter/material.dart';
import 'package:image_barcode_collector/entities/my_images.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MyImages.loadAssetCount();
  runApp(const App());
}



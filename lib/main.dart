import 'package:flutter/material.dart';
import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/storages/component_view_storage.dart';
import 'package:image_barcode_collector/storages/image_storage.dart';

import 'app.dart';

Future<void> main() async {

  // 앱의 endpoint, 변수 초기화
  WidgetsFlutterBinding.ensureInitialized();
  // await ImageStorage.clear();

  ImageStorage.sortImagesByCreatedTime();

  await MyImages.loadAssetCount();

  var assetCount = MyImages.getAssetCount();
  var loadedCount = await ImageStorage.getLastOffset();
  ComponentViewStorage.setShowProgressBar(assetCount != loadedCount);

  runApp(const App());
}



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/storages/component_view_storage.dart';
import 'package:image_barcode_collector/storages/image_storage.dart';
import 'package:image_barcode_collector/views/home.dart';

import 'app.dart';

Future<void> main() async {

  // 앱의 endpoint, 변수 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await HomeRefresher.refresh();

  runApp(const App());
}



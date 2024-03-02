import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_barcode_collector/states/image_state.dart';

import 'components/error_dialog.dart';
import 'views/home.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});


  @override
  Widget build(BuildContext context) {
    PlatformDispatcher.instance.onError = (error, stack) {
      print('Global error handler: ${stack}');
      // 다이얼로그 표시
      showErrorDialog(error.toString());
      return false;
    };

    return MaterialApp(
      navigatorKey: navigatorKey,
      builder: (context, widget) {
        Widget error = const Text('...rendering error...');
        ErrorWidget.builder = (errorDetails) => error;
        if (widget != null) return widget;
        throw StateError('widget is null');
      },
      debugShowCheckedModeBanner: false,
      home:
          BlocProvider(create: (context) => ImageCubit(), child: const Home()),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
    );
  }
}

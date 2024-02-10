import 'dart:io';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  File? file;
  ImageView({super.key, this.file});

  @override
  Widget build(BuildContext context) {
    ScreenBrightness.instance.setScreenBrightness(1.0);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Image View'),
          centerTitle: true,
          elevation: 0,
        ),
        body:  Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.file(file!),
          ],
        ),
    );
  }
}

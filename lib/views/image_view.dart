import 'dart:io';
import 'package:image_barcode_collector/entities/my_image.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  MyImage? myImage;

  ImageView({super.key, this.myImage});

  @override
  Widget build(BuildContext context) {
    ScreenBrightness.instance.setScreenBrightness(1.0);

    return FutureBuilder<File?>(
        future: myImage?.getAssetEntity()?.file,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Image View'),
              centerTitle: true,
              elevation: 0,
            ),
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.file(snapshot.data as File),
              ],
            ),
          );
        });
  }
}

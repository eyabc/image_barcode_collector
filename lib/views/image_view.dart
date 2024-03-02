import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_barcode_collector/components/ad_google_banner.dart';
import 'package:image_barcode_collector/entities/my_image.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ImageView extends StatelessWidget {
  MyImage? myImage;

  ImageView({super.key, this.myImage});

  @override
  Widget build(BuildContext context) {
    ScreenBrightness.instance.setScreenBrightness(1.0);

    return FutureBuilder<File?>(
        future: myImage?.getAssetEntity()?.file,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              !snapshot.hasData) {
            return const Center();
          }

          return Scaffold(
              appBar: AppBar(),
              body: SafeArea(
                  child: Column(children: [
                Expanded(
                    child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.file(snapshot.data as File),
                  ],
                )),
                const AdGoogleBanner()
              ])));
        });
  }
}

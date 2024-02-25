import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

    TargetPlatform os = Theme.of(context).platform;

    BannerAd banner = BannerAd(
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {},
        onAdLoaded: (_) {},
      ),
      size: AdSize.banner,
      adUnitId: UNIT_ID[os == TargetPlatform.iOS ? 'ios' : 'android']!,
      request: const AdRequest(),
    )..load();

    return FutureBuilder<File?>(
        future: myImage?.getAssetEntity()?.file,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
            return const Center();
          }

          return Scaffold(
            appBar: AppBar(
              leading: AdWidget(
                ad: banner,
              ),
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

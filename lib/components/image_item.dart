import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_barcode_collector/entities/my_image.dart';
import 'package:photo_manager/photo_manager.dart';

import '../views/image_view.dart';

class ImageItem extends StatelessWidget {
  final MyImage? myImage;

  const ImageItem({Key? key, required this.myImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: myImage?.getAssetEntity()?.file,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ImageView(myImage: myImage)));
              },
              child: Container(
                  width: 10.0,
                  height: 10.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Image.file(snapshot.data as File, cacheWidth: 100).image, // <--- .image added here
                  ))));
        }

        return const Center();
      },
    );
  }
}

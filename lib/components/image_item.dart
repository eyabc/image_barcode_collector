import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../views/image_view.dart';

class ImageItem extends StatelessWidget {
  final AssetEntity? assetEntity;

  const ImageItem({Key? key, required this.assetEntity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: assetEntity?.file,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ImageView(file: snapshot.data)));
              },
              child: Container(
                  width: 10.0,
                  height: 10.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Image.file(snapshot.data as File).image, // <--- .image added here
                  ))));
        }

        return const Center();
      },
    );
  }
}

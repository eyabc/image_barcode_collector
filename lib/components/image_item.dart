import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageItem extends StatelessWidget {
  final AssetEntity assetEntity;

  const ImageItem({Key? key, required this.assetEntity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?> (
      future: assetEntity.file,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.file(snapshot.data!);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

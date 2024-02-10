import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:photo_manager/photo_manager.dart';

import 'image_item.dart';

class GridGallery extends StatefulWidget {
  const GridGallery({super.key});

  @override
  State<GridGallery> createState() => _GridGallery();
}

class _GridGallery extends State<GridGallery> {
  List<AssetEntity> _imageList = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {

    if (await PhotoManager.requestPermissionExtend() != PermissionState.authorized) {
      return;
    }

    final assets = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (assets.isEmpty) {
      return;
    }

    var offset = 0;
    const size = 10, end = 100;
    List<AssetEntity> result = [];

    final BarcodeScanner barcodeScanner = BarcodeScanner();

    while(offset < end) {
      List<AssetEntity> list = await assets[0].getAssetListRange(start: offset, end: offset += size);
      for (AssetEntity entity in list) {
        final barcodeResult = await barcodeScanner.processImage(InputImage.fromFile(await entity.file as File));
        if (barcodeResult.isNotEmpty) {
          result.add(entity);
        }
      }
    }

    setState(() {
      _imageList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: _imageList!.length,
      itemBuilder: (context, index) {
        return ImageItem(assetEntity: _imageList![index]);
      },
    );
  }
}

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
    const size = 100, end = 500;
    List<AssetEntity> result = [];

    final BarcodeScanner barcodeScanner = BarcodeScanner();

    while(offset < end || result.length > 20) {
      List<Future<List<Barcode>>> task = [];

      var assetList = await assets[0].getAssetListRange(start: offset, end: offset += size);
      for (AssetEntity entity in assetList) {
        task.add(barcodeScanner.processImage(InputImage.fromFile(await entity.file as File)));
      }

      List<List<Barcode>> list = await Future.wait(task as Iterable<Future<List<Barcode>>>);
      for(int i = 0; i< list.length ; i++) {
        if (list[i].isNotEmpty) {
          result.add(assetList[i]);
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

import 'package:flutter/material.dart';
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

    while(offset < end) {
      result.addAll(await assets[0].getAssetListRange(start: offset, end: offset += size));
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

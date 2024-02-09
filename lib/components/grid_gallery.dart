import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'image_item.dart';

class GridGallery extends StatefulWidget {
  const GridGallery({super.key});

  @override
  State<GridGallery> createState() => _GridGallery();
}

class _GridGallery extends State<GridGallery> {
  List<AssetEntity>? _imageList;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (result == PermissionState.authorized) {
      final assets =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      if (assets.isNotEmpty) {
        final assetList = await assets[0].getAssetListRange(
            start: 0, end: 100); // Adjust the range as needed
        setState(() {
          _imageList = assetList;
        });
      }
    }
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

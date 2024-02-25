import 'dart:io';
import 'dart:async';

import 'package:photo_manager/photo_manager.dart';

import '../entities/my_image.dart';
import '../entities/my_images.dart';
import '../entities/pageable.dart';

class ImageLoader {
  static int _assetCount = -1;

  static Future<List<AssetPathEntity>> getAlbumList() async =>
      await PhotoManager.getAssetPathList(type: RequestType.image);

  static Future<void> loadAssetCount() async {
    final albums = await getAlbumList();
    _assetCount = await albums[0].assetCountAsync;
  }



  /**
   * 앨범에서 pageable 로 AssetEntity 들을 가져온다.
   * todo - 앨범은 쉽게 교체할 수 있도록 Elbum 다형성 처리한다.
   */
  static Future<MyImages> loadAssetListByPageable(Pageable pageable) async {
    final albums = await getAlbumList();
    if (albums.isEmpty) {
      return MyImages.empty();
    }

    var assetList = await albums[0].getAssetListPaged(page: pageable.page, size: pageable.size);
    return MyImages.fromAssetEntityList(assetList);
  }

  static Future<List<File?>> getFiles(List<MyImage> images) async {
    var fileTasks = images.map((image) => image.getAssetEntity().file).toList();
    return await Future.wait(fileTasks);
  }

  static getAssetCount() => _assetCount;
}
import 'dart:io';
import 'dart:async';

import 'package:image_barcode_collector/components/error_dialog.dart';
import 'package:image_barcode_collector/entities/album_of_screenshot.dart';

import '../entities/album.dart';
import '../entities/my_image.dart';
import '../entities/my_images.dart';
import '../entities/pageable.dart';

class ImageLoader {
  static int _assetCount = -1;
  static Album album = AlbumOfScreenshot();

  static bool isLoaded() =>  _assetCount != -1;

  /// 앨범의 자산 수를 로드합니다.
  static Future<int> loadAssetCount() async {
    try {
      final albums = await album.get();
      return await albums.assetCountAsync;
    } catch (e) {
      showErrorDialog(e.toString());
    }

    return 0;
  }

  /**
   * 앨범에서 pageable 로 AssetEntity 들을 가져옵니다.
   * todo - 앨범은 쉽게 교체할 수 있도록 Elbum 다형성 처리합니다.
   */
  static Future<MyImages> loadAssetListByPageable(Pageable pageable) async {
    final albums = await album.get();

    final assetList = await albums.getAssetListPaged(page: pageable.page, size: pageable.size);
    return MyImages.fromAssetEntityList(assetList);
  }

  /// 주어진 이미지 목록에 대한 파일 목록을 비동기적으로 가져옵니다.
  static Future<List<File?>> getFiles(List<MyImage> images) async {
    var fileTasks = images.map((image) => image.getAssetEntity().file).toList();
    return await Future.wait(fileTasks);
  }

  /// 앨범의 자산 수를 반환합니다.
  static getAssetCount() {
    return _assetCount;
  }
}
import 'dart:io';
import 'dart:async';

import 'package:image_barcode_collector/components/error_dialog.dart';

import '../entities/album.dart';

class ImageLoader {
  static int _assetCount = -1;

  /// 앨범의 자산 수를 로드합니다.
  static Future<int> loadAssetCount() async {
    try {
      final albums = await Album.from();
      return _assetCount = await albums.countAsset();
    } catch (e) {
      showErrorDialog(e.toString());
    }

    return 0;
  }

}
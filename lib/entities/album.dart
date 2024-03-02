import 'package:image_barcode_collector/entities/album_of_screenshot.dart';
import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:photo_manager/photo_manager.dart';

class Album {
  late AssetPathEntity album;

  static fromAssetPathEntity(AssetPathEntity album) {
    var instance = Album();
    instance.album = album;
    return instance;
  }

  static Future<Album> from() async {
    return AlbumOfScreenshot.from();
  }

  Future<int> countAsset() async {
    return await album.assetCountAsync;
  }

  Future<MyImages> getAssetListPaged(Pageable pageable) async {
    final assetList = await album.getAssetListPaged(page: pageable.page, size: pageable.size);
    return MyImages.fromAssetEntityList(assetList);
  }
}


import 'package:image_barcode_collector/entities/album.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumOfRecent extends Album {

  @override
  Future<AssetPathEntity> get() async =>
      (await PhotoManager.getAssetPathList(type: RequestType.image))[0];

}
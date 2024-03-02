
import 'package:image_barcode_collector/entities/album.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumOfRecent {

  Future<Album> load() async =>
      Album.fromAssetPathEntity((await PhotoManager.getAssetPathList(type: RequestType.image))[0]);

}

import 'package:image_barcode_collector/entities/album.dart';
import 'package:photo_manager/photo_manager.dart';

import '../utils/plugin.dart';

class AlbumOfScreenshot {

  static Future<Album> from() async {
    final List<PMDarwinAssetCollectionType> pathTypeList = [ PMDarwinAssetCollectionType.smartAlbum ]; // use your need type
    final List<PMDarwinAssetCollectionSubtype> pathSubTypeList = [ PMDarwinAssetCollectionSubtype.smartAlbumScreenshots ]; // use your need type
    final darwinPathFilterOption = PMDarwinPathFilter(
      type: pathTypeList,
      subType: pathSubTypeList,
    );

    PMPathFilter pathFilter = PMPathFilter(darwin: darwinPathFilterOption);
    var assetPathList = await photoManagerPlugin.getAssetPathList(
      hasAll: true,
      onlyAll: false,
      type: RequestType.image,
      filterOption: null,
      pathFilterOption: pathFilter,
    );

    return Album.fromAssetPathEntity(assetPathList[1]);
  }

}
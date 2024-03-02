
import 'package:image_barcode_collector/entities/album.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumOfScreenshot extends Album {
  static PhotoManagerPlugin plugin = PhotoManagerPlugin();

  @override
  Future<List<AssetPathEntity>> get() async {
    final List<PMDarwinAssetCollectionType> pathTypeList = [ PMDarwinAssetCollectionType.album]; // use your need type
    final List<PMDarwinAssetCollectionSubtype> pathSubTypeList = [ PMDarwinAssetCollectionSubtype.smartAlbumScreenshots ]; // use your need type
    final darwinPathFilterOption = PMDarwinPathFilter(
      type: pathTypeList,
      subType: pathSubTypeList,
    );

    PMPathFilter pathFilter = PMPathFilter(darwin: darwinPathFilterOption);
    return plugin.getAssetPathList(
      hasAll: true,
      onlyAll: false,
      type: RequestType.image,
      filterOption: null,
      pathFilterOption: pathFilter,
    );

  }

}
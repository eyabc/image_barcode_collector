import 'package:photo_manager/src/types/entity.dart';

class MyImage {

  late final AssetEntity _assetEntity;

  MyImage(AssetEntity e) {
    _assetEntity = e;
  }

  AssetEntity getAssetEntity() {
    return _assetEntity;
  }

}
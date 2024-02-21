import 'package:photo_manager/src/types/entity.dart';

class MyImage {

  late AssetEntity? _assetEntity;
  late String _id;

  MyImage({ required String id, AssetEntity? assetEntity }) {
    _assetEntity = assetEntity;
    _id = id;
  }

  String getId() {
    return _id;
  }


  static of(String id) {
    var myImage = MyImage(id: id);
    myImage._id = id;
    myImage._assetEntity = AssetEntity(id: id, typeInt: 0,
      width: 100,
      height: 100);
    return myImage;
  }

  static ofAssetEntity(AssetEntity assetEntity) {
    var myImage = MyImage(assetEntity: assetEntity, id: assetEntity.id);
    return myImage;
  }


  AssetEntity? getAssetEntity() {
    return _assetEntity;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyImage &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
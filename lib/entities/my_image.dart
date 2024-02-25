
import 'dart:core';

import 'package:photo_manager/src/types/entity.dart';

class MyImage<Comparator>  {

  final AssetEntity _assetEntity;
  late String _id;
  late int _createDateSecond;
  late DateTime createDateTime;

  MyImage(this._assetEntity){
    createDateTime = _assetEntity.createDateTime;
    _createDateSecond = _assetEntity.createDateSecond ?? 0;
    _id = _assetEntity.id;
  }

  String getId() {
    return _id;
  }

  AssetEntity getAssetEntity() {
    return _assetEntity;
  }

  int getCreateDateSecond() {
    return _createDateSecond;
  }

  static fromId(String id) async {
    AssetEntity assetEntity = await AssetEntity.fromId(id) ?? AssetEntity(id: id, typeInt: 0, width: 100, height: 100);
    var myImage = MyImage(assetEntity);
    return myImage;
  }

  static ofAssetEntity(AssetEntity assetEntity) {
    return MyImage(assetEntity);
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
import 'dart:io';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:photo_manager/photo_manager.dart';

import 'my_image.dart';

class MyImages {
  final List<MyImage> _list = [];

  List<MyImage> getList() {
    return List.unmodifiable(_list);
  }

  List<AssetEntity> getEntities() {
    return _list.map((e) => e.getAssetEntity()).toList();
  }

  Future<void> loadBarcodeImages(Pageable pageable) async {
    List<AssetEntity> result = [];

    if (await checkImageAccessPermission()) {
      return;
    }

    final assets = await getElbumList();
    if (assets.isEmpty) {
      return;
    }

    final assetList = await assets[0].getAssetListRange(start: pageable.offset(), end: pageable.offset() + pageable.size);
    List<Future<File?>> fileTask = [];
    for (AssetEntity entity in assetList) {
      fileTask.add(entity.file);
    }

    final BarcodeScanner barcodeScanner = BarcodeScanner();
    List<File?> files = await Future.wait(fileTask);
    List<Future<List<Barcode>>> task = [];
    for (File? file in files) {
      task.add(barcodeScanner.processImage(InputImage.fromFile(file!)));
    }

    List<List<Barcode>> list = await Future.wait(task);
    for (int i = 0; i < list.length; i++) {
      if (list[i].isNotEmpty) {
        result.add(assetList[i]);
      }
    }

    addAll(result);
  }

  Future<List<AssetPathEntity>> getElbumList() async => await PhotoManager.getAssetPathList(type: RequestType.image);

  Future<bool> checkImageAccessPermission() async {
    return await PhotoManager.requestPermissionExtend() !=
      PermissionState.authorized;
  }

  void addAll(List<AssetEntity> result) {
    _list.addAll(result.map((e) => MyImage(e)));
  }

  void addMyImages(MyImages myImages) {
    _list.addAll(myImages._list);
  }

  length() {
    return _list.length;
  }

  getIndex(int index) {
    return _list[index];
  }
}

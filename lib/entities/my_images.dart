import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:photo_manager/photo_manager.dart';

import 'my_image.dart';

class MyImages {
  final Set<MyImage> _list = {};
  static int assetCount = -1;

  static MyImages ofEmpty() {
    return MyImages();
  }

  static MyImages ofMyImages(List<MyImage> myImages) {
    var result = ofEmpty();
    result._list.addAll(myImages);
    return result;
  }

  static MyImages ofMyImagesSet(Set<MyImage> myImages) {
    var result = ofEmpty();
    result._list.addAll(myImages);
    return result;
  }

  static MyImages of(List<String> stringList) {
    var result = ofEmpty();
    for (String id in stringList) {
      result._list.add(MyImage.of(id));
    }
    return result;
  }

  List<MyImage> getList() {
    return List.unmodifiable(_list);
  }

  static Future<void> loadAssetCount() async {
    final assets = await _getElbumList();
    assetCount = await (await assets[0] as AssetPathEntity).assetCountAsync;
  }

  static int getAssetCount() {
    return assetCount;
  }

  // 분리
  Future<MyImages> loadBarcodeImages(Pageable pageable) async {
    if (await checkImageAccessPermission()) {
      return ofEmpty();
    }

    final assets = await _getElbumList();
    if (assets.isEmpty) {
      return ofEmpty();
    }

    final assetList = await assets[0].getAssetListPaged(page: pageable.page, size: pageable.size);
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
    MyImages result = ofEmpty();
    for (int i = 0; i < list.length; i++) {
      if (list[i].isNotEmpty) {
        result._list.add(MyImage.ofAssetEntity(assetList[i]));
      }
    }

    return result;
  }

  static Future<List<AssetPathEntity>> _getElbumList() async => await PhotoManager.getAssetPathList(type: RequestType.image);

  Future<bool> checkImageAccessPermission() async {
    return await PhotoManager.requestPermissionExtend() !=
      PermissionState.authorized;
  }

  void addAllMyImages(List<MyImage> result) {
    _list.addAll(result);
  }

  MyImages diffMyImages(MyImages myImages) {
    return ofMyImagesSet(myImages._list.difference(_list));
  }

  // 일급함수로 만들어볼것
  addMyImages(MyImages myImages) {
    _list.addAll(myImages._list);
  }

  length() {
    return _list.length;
  }

  isEmpty() {
    return _list.isEmpty;
  }

  getIndex(int index) {
    return _list.elementAt(index);
  }

  List<String> toStringList() {
    List<String> result = [];
    for (MyImage myImage in _list) {
      result.add(myImage.getId());
    }
    return result;
  }

  MyImages sublist(Pageable pageable) {
    if (_list.length <= pageable.nextOffset()) {
      return ofEmpty();
    }

    return ofMyImages(_list.toList().sublist(pageable.offset(), pageable.nextOffset()));
  }

}

import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:photo_manager/photo_manager.dart';

import 'my_image.dart';

class MyImages {
  final List<MyImage> _list = [];

  static MyImages of(List<String> stringList) {
    var result = MyImages();
    List<MyImage> list = [];
    for (String id in stringList) {
      list.add(MyImage.of(id));
    }
    result.addAllMyImages(list);
    return result;
  }

  List<MyImage> getList() {
    return List.unmodifiable(_list);
  }

  List<AssetEntity?> getEntities() {
    return _list.map((e) => e.getAssetEntity()).toList();
  }

  Future<MyImages> loadBarcodeImages(Pageable pageable) async {
    List<AssetEntity> result = [];

    if (await checkImageAccessPermission()) {
      return MyImages();
    }

    final assets = await getElbumList();
    if (assets.isEmpty) {
      return MyImages();
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
    for (int i = 0; i < list.length; i++) {
      if (list[i].isNotEmpty) {
        result.add(assetList[i]);
      }
    }

    addAll(result);

    var myImages = MyImages();
    myImages.addAll(result);
    return myImages;
  }

  Future<List<AssetPathEntity>> getElbumList() async => await PhotoManager.getAssetPathList(type: RequestType.image);

  Future<bool> checkImageAccessPermission() async {
    return await PhotoManager.requestPermissionExtend() !=
      PermissionState.authorized;
  }

  void addAll(List<AssetEntity> result) {
    _list.addAll(result.map((e) => MyImage.ofAssetEntity(e)));
  }

  void addAllMyImages(List<MyImage> result) {
    _list.addAll(result);
  }


  void addMyImages(MyImages myImages) {
    _list.addAll(myImages._list);
  }

  length() {
    return _list.length;
  }

  isEmpty() {
    return _list.isEmpty;
  }

  getIndex(int index) {
    return _list[index];
  }

  List<String> toStringList() {
    List<String> result = [];
    for (MyImage myImage in _list) {
      result.add(myImage.getId());
    }
    return result;
  }

  MyImages sublist(Pageable pageable) {
    var result = MyImages();

    if (_list.length <= pageable.nextOffset()) {
      return result;
    }

    result.addAllMyImages(_list.sublist(pageable.offset(), pageable.nextOffset()));
    return result;
  }

}

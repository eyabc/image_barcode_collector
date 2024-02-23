import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:image_barcode_collector/storages/image_storage.dart';
import 'package:photo_manager/photo_manager.dart';

import 'my_image.dart';

class MyImages {
  final Set<MyImage> _set = {};
  static int _assetCount = -1;

  static MyImages ofEmpty() {
    return MyImages();
  }

  static MyImages ofMyImages(List<MyImage> myImages) {
    var result = ofEmpty();
    result._set.addAll(myImages);
    return result;
  }

  static MyImages ofMyImagesSet(Set<MyImage> myImages) {
    var result = ofEmpty();
    result._set.addAll(myImages);
    return result;
  }

  static MyImages ofAssetEntityList(List<AssetEntity> assetEntities) {
    MyImages result = MyImages();
    for (var o in assetEntities) {
      result.add(MyImage.ofAssetEntity(o));
    }
    return result;
  }

  static of(List<String> stringList) async {
    var result = ofEmpty();
    for (String id in stringList) {
      await MyImage.of(id).then((res) =>
          result._set.add(res)
      );
    }
    return result;
  }

  List<MyImage> getList() {
    return List.unmodifiable(_set);
  }

  static Future<void> loadAssetCount() async {
    final assets = await _getElbumList();
    _assetCount = await (await assets[0] as AssetPathEntity).assetCountAsync;
  }

  static int getAssetCount() {
    return _assetCount;
  }

  /**
   * 앨범에서 pageable 로 AssetEntity 들을 가져온다.
   * todo - 앨범은 쉽게 교체할 수 있도록 Elbum 다형성 처리한다.
   */
  Future<MyImages> loadAssetListByPageable(Pageable pageable) async {
    final assets = await _getElbumList();
    if (assets.isEmpty) {
      return MyImages.ofEmpty();
    }

    return MyImages.ofAssetEntityList(await assets[0].getAssetListPaged(page: pageable.page, size: pageable.size));
  }

  /**
   * assetList 들이 이미 스토리지에 저장되었는지 확인하고 스토리지에 저장되지 않는 것만 가져온다.
   * 내 이미지에서 targetImages 를 차집합 한다.
   *
   */
  MyImages filterNotIn(MyImages targetImages) {
    return MyImages.ofMyImagesSet(_set.difference(targetImages._set));
  }

  Future<List<File?>> getFiles() async {
    List<Future<File?>> fileTask = [];
    for (MyImage image in _set) {
      fileTask.add(image.getAssetEntity().file);
    }
    return await Future.wait(fileTask);
  }

  static final barcodeScanner = BarcodeScanner();

  Future<MyImages> filterBarcodeImages() async {
    List<File?> files = await getFiles();
    List<Future<List<Barcode>>> task = [];
    for (File? file in files) {
      task.add(barcodeScanner.processImage(InputImage.fromFile(file!)));
    }

    var list = (await Future.wait(task));
    MyImages result = ofEmpty();
    for (int i = 0; i < list.length; i++) {
      if (list[i].isNotEmpty) {
        result._set.add(_set.elementAt(i));
      }
    }

    return result;
  }

  Future<MyImages> loadBarcodeImages(Pageable pageable) async {
    return (await loadAssetListByPageable(pageable))
        .filterNotIn(await imageStorage.getImages())
        .filterBarcodeImages();
  }

  static Future<List<AssetPathEntity>> _getElbumList() async => await PhotoManager.getAssetPathList(type: RequestType.image);

  void addAllMyImages(List<MyImage> result) {
    _set.addAll(result);
  }

  MyImages diffMyImages(MyImages myImages) {
    return ofMyImagesSet(myImages._set.difference(_set));
  }

  // 일급함수로 만들어볼것
  addMyImages(MyImages myImages) {
    _set.addAll(myImages._set);
  }

  length() {
    return _set.length;
  }

  isEmpty() {
    return _set.isEmpty;
  }

  getIndex(int index) {
    return _set.elementAt(index);
  }

  List<String> toStringList() {
    List<String> result = [];
    for (MyImage myImage in _set) {
      result.add(myImage.getId());
    }
    return result;
  }

  MyImages sublist(Pageable pageable) {
    if (_set.length <= pageable.nextOffset()) {
      return ofEmpty();
    }

    return ofMyImages(_set.toList().sublist(pageable.offset(), pageable.nextOffset()));
  }

  // immutable
  MyImages sortByCreatedTime() {
    List<MyImage> result = _set.toList();
    result.sort((a, b) => a.getCreateDateSecond() - b.getCreateDateSecond());
    return MyImages.ofMyImages(result);
  }

  void add(MyImage myImage) {
    _set.add(myImage);
  }

}

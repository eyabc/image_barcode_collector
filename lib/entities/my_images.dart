import 'dart:async';
import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:image_barcode_collector/storages/image_storage.dart';
import 'package:photo_manager/photo_manager.dart';

import 'my_image.dart';


PhotoManagerPlugin plugin = PhotoManagerPlugin();
BarcodeScanner barcodeScanner = BarcodeScanner();

class MyImages {
  final Set<MyImage> _images = {};
  static int _assetCount = -1;

  static const Duration timeoutDuration = Duration(seconds: 1);

  static MyImages empty() => MyImages();

  static MyImages fromList(List<MyImage> images) {
    var result = empty()..addAll(images);
    return result;
  }

  static MyImages fromSet(Set<MyImage> images) {
    var result = empty()..addAll(images.toList());
    return result;
  }

  static MyImages fromAssetEntityList(List<AssetEntity> assetEntities) {
    MyImages result = empty();
    for (var o in assetEntities) {
      result.add(MyImage.ofAssetEntity(o));
    }
    return result;
  }

  static Future<MyImages> fromIds(List<String> ids) async {
    var result = empty();
    for (String id in ids) {
      try {
        var image = await MyImage.fromId(id);
        result.add(image);
      } catch (e) {
        print('Error loading image with id: $id - $e');
      }
    }
    return result;
  }

  List<MyImage> getList() => List.unmodifiable(_images);

  void addAll(List<MyImage> images) => _images.addAll(images);

  MyImages diff(MyImages otherImages) => MyImages.fromSet(otherImages._images.difference(_images));

  void add(MyImage image) => _images.add(image);

  int length() => _images.length;

  bool isEmpty() => _images.isEmpty;

  MyImage getIndex(int index) => _images.elementAt(index);

  List<String> toStringList() => _images.map((image) => image.getId()).toList();

  MyImages sublist(Pageable pageable) {
    if (_images.length <= pageable.nextOffset()) {
      return empty();
    }
    return fromList(_images.toList().sublist(pageable.offset(), pageable.nextOffset()));
  }

  MyImages sortByCreatedTime() {
    var sortedImages = _images.toList()..sort((a, b) => a.getCreateDateSecond() - b.getCreateDateSecond());
    return MyImages.fromList(sortedImages);
  }

  // 여기 아래에서 부터는 분리가능성이 큰 메서드들

  static Future<List<AssetPathEntity>> _getAlbumList() async =>
      await PhotoManager.getAssetPathList(type: RequestType.image);

  static Future<void> loadAssetCount() async {
    final albums = await _getAlbumList();
    _assetCount = await (albums[0]).assetCountAsync;
  }

  static int getAssetCount() => _assetCount;

  /**
   * 앨범에서 pageable 로 AssetEntity 들을 가져온다.
   * todo - 앨범은 쉽게 교체할 수 있도록 Elbum 다형성 처리한다.
   */
  Future<MyImages> loadAssetListByPageable(Pageable pageable) async {
    final albums = await _getAlbumList();
    if (albums.isEmpty) {
      return empty();
    }

    var assetList = await albums[0].getAssetListPaged(page: pageable.page, size: pageable.size);
    return fromAssetEntityList(assetList);
  }

  /**
   * assetList 들이 이미 스토리지에 저장되었는지 확인하고 스토리지에 저장되지 않는 것만 가져온다.
   * 내 이미지에서 targetImages 를 차집합 한다.
   *
   */
  MyImages filterNotIn(MyImages targetImages) => MyImages.fromSet(_images.difference(targetImages._images));

  Future<List<File?>> getFiles() async {
    var fileTasks = _images.map((image) => image.getAssetEntity().file).toList();
    return await Future.wait(fileTasks);
  }

  Future<MyImages> filterBarcodeImages() async {
    var tasks = _images.map((myImage) async {
      try {
        var path = await plugin.getFullFile(myImage.getId(), isOrigin: false).timeout(timeoutDuration);
        if (path != null) {
          var inputImage = InputImage.fromFilePath(path);
          var barcodes = await BarcodeScanner().processImage(inputImage);
          if (barcodes.isNotEmpty) {
            return myImage;
          }
        }
      } on TimeoutException {
        print('Error processing barcode for image with id: ${myImage.getId()}');
      }
      return null;
    });

    var list = await Future.wait(tasks);
    return MyImages.fromSet(list.where((image) => image != null).cast<MyImage>().toSet());
  }

  Future<MyImages> loadBarcodeImages(Pageable pageable) async {
    return (await loadAssetListByPageable(pageable))
        .filterNotIn(await imageStorage.getImages())
        .filterBarcodeImages();
  }

  // 일급함수로 만들어볼것
  addMyImages(MyImages myImages) => _images.addAll(myImages._images);

}

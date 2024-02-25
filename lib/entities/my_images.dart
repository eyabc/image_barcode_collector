import 'dart:async';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:photo_manager/photo_manager.dart';

import 'my_image.dart';

PhotoManagerPlugin plugin = PhotoManagerPlugin();
BarcodeScanner barcodeScanner = BarcodeScanner();

class MyImages {
  final Set<MyImage> _images = {};

  static const Duration timeoutDuration = Duration(seconds: 1);

  /// 빈 MyImages 인스턴스를 생성합니다.
  static MyImages empty() => MyImages();

  /// MyImage 목록에서 MyImages 인스턴스를 생성합니다.
  static MyImages fromList(List<MyImage> images) {
    var result = empty()..addAll(images);
    return result;
  }

  /// MyImage 집합에서 MyImages 인스턴스를 생성합니다.
  static MyImages fromSet(Set<MyImage> images) {
    var result = empty()..addAll(images.toList());
    return result;
  }

  /// AssetEntity 목록에서 MyImages 인스턴스를 생성합니다.
  static MyImages fromAssetEntityList(List<AssetEntity> assetEntities) {
    MyImages result = empty();
    for (var o in assetEntities) {
      result.add(MyImage.ofAssetEntity(o));
    }
    return result;
  }

  /// ID 목록에서 MyImages 인스턴스를 비동기적으로 생성합니다.
  static Future<MyImages> fromIds(List<String> ids) async {
    var result = empty();
    for (String id in ids) {
      try {
        var image = await MyImage.fromId(id);
        result.add(image);
      } catch (e) {
        print('ID가 $id인 이미지를 불러오는 중 오류 발생: $e');
      }
    }
    return result;
  }

  /// 현재 MyImages의 MyImage 목록을 반환합니다.
  List<MyImage> getList() => List.unmodifiable(_images);

  /// 주어진 MyImage 목록을 현재 MyImages에 추가합니다.
  void addAll(List<MyImage> images) => _images.addAll(images);

  /// 현재 MyImages와 다른 MyImages 간의 차집합을 반환합니다.
  MyImages diff(MyImages otherImages) => MyImages.fromSet(otherImages._images.difference(_images));

  /// MyImage를 현재 MyImages에 추가합니다.
  void add(MyImage image) => _images.add(image);

  /// 현재 MyImages의 MyImage 개수를 반환합니다.
  int length() => _images.length;

  /// 현재 MyImages가 비어 있는지 여부를 반환합니다.
  bool isEmpty() => _images.isEmpty;

  /// 주어진 인덱스에 해당하는 MyImage를 반환합니다.
  MyImage getIndex(int index) => _images.elementAt(index);

  /// 현재 MyImages의 MyImage ID 목록을 반환합니다.
  List<String> toStringList() => _images.map((image) => image.getId()).toList();

  /// 페이지 정보를 기반으로 MyImages의 일부를 반환합니다.
  MyImages sublist(Pageable pageable) {
    if (_images.length <= pageable.nextOffset()) {
      return empty();
    }
    return fromList(_images.toList().sublist(pageable.offset(), pageable.nextOffset()));
  }

  /// MyImages를 생성일을 기준으로 정렬한 새로운 MyImages를 반환합니다.
  MyImages sortByCreatedTime() {
    var sortedImages = _images.toList()..sort((b, a) => a.getCreateDateSecond() - b.getCreateDateSecond());
    return MyImages.fromList(sortedImages);
  }

  // 여기 아래에서 부터는 분리가능성이 큰 메서드들

  /**
   * assetList 들이 이미 스토리지에 저장되었는지 확인하고 스토리지에 저장되지 않는 것만 가져옵니다.
   * 내 이미지에서 targetImages를 차집합 합니다.
   *
   */
  MyImages filterNotIn(MyImages targetImages) => MyImages.fromSet(_images.difference(targetImages._images));

  // 일급함수로 만들어볼것
  /// 다른 MyImages를 현재 MyImages에 추가합니다.
  addMyImages(MyImages myImages) => _images.addAll(myImages._images);
}
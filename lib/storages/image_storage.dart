import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// todo 버그방지를 위해 _KEY 별 싱글턴으로 만들기
class _ImageStorageFactory {

  final String _KEY;

  _ImageStorageFactory(this._KEY);

  static of(String keyName) {
    return _ImageStorageFactory(keyName);
  }

  Future<MyImages> getImages() async {
    final prefs = await SharedPreferences.getInstance();
    return await MyImages.fromIds(prefs.getStringList(_KEY) ?? []);
  }

  Future<MyImages> getImagesByPage(Pageable pageable) async {
    return (await getImages()).sublist(pageable);
  }

  Future<MyImages> addImages(MyImages myImages) async {
    MyImages value = await getImages();
    var diff = value.diff(myImages);
    value.addMyImages(myImages);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_KEY, value.toStringList());
    // 추가에 성공한 리스트 리턴
    return diff;
  }

  Future<MyImages> setImages(MyImages myImages) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_KEY, myImages.toStringList());
    // 추가에 성공한 리스트 리턴
    return myImages;
  }

  Future<int> size() async {
    MyImages myImages = await getImages();
    return myImages.length();
  }

  Future<void> sortImagesByCreatedTime() async {
    MyImages myImages = await getImages();
    await setImages(myImages.sortByCreatedTime());
  }

}

/**
 * 키가 커지면 샤딩해서 가져오기로 변경
 * 저장된 이미지 키의 Set<String>
 * 특별한 기능이 추가되어야 하면 컴포지션으로 변경하기
 */

final imageStorage = _ImageStorageFactory.of("image");
final scannedImageStorage = _ImageStorageFactory.of("image:scanned");



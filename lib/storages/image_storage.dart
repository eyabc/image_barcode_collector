import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageStorage {

  // 키가 커지면 샤딩해서 가져오기로 변경
  static const String _KEY_NAME_IMAGE = "image";
  static const String _KEY_NAME_LAST_OFFSET = "image:last-offset";

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static Future<MyImages> getImages() async {
    final prefs = await SharedPreferences.getInstance();
    return await MyImages.of(prefs.getStringList(_KEY_NAME_IMAGE) ?? []);
  }

  static Future<MyImages> getImagesByPage(Pageable pageable) async {
    return (await getImages()).sublist(pageable);
  }

  static Future<MyImages> addImages(MyImages myImages) async {
    MyImages value = await getImages();
    var diff = value.diffMyImages(myImages);
    value.addMyImages(myImages);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_KEY_NAME_IMAGE, value.toStringList());
    // 추가에 성공한 리스트 리턴
    return diff;
  }

  static Future<MyImages> setImages(MyImages myImages) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_KEY_NAME_IMAGE, myImages.toStringList());
    // 추가에 성공한 리스트 리턴
    return myImages;
  }

  static Future<int> size() async {
    MyImages myImages = await getImages();
    return myImages.length();
  }

  static Future<int> getLastOffset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_KEY_NAME_LAST_OFFSET) ?? 0;
  }

  static Future<void> setLastOffset(int offset) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_KEY_NAME_LAST_OFFSET, offset);
  }

  static Future<void> sortImagesByCreatedTime() async {
    MyImages myImages = await getImages();
    myImages.sortByCreatedTime();
    setImages(myImages);
  }


}
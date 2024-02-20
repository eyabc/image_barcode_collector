import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageStorage {

  // 키가 커지면 샤딩해서 가져오기로 변경
  static const String _KEY_NAME_IMAGE = "image";
  static const String _KEY_NAME_LAST_PAGE = "image:last-page";

  static Future<MyImages> getImages() async {
    final prefs = await SharedPreferences.getInstance();
    return MyImages.of(prefs.getStringList(_KEY_NAME_IMAGE) ?? []);
  }

  static Future<MyImages> getImagesByPage(Pageable pageable) async {
    return (await getImages()).sublist(pageable);
  }

  static Future<void> addImages(MyImages myImages) async {
    MyImages value = await getImages();
    value.addMyImages(myImages);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_KEY_NAME_IMAGE, value.toStringList());
  }

  static Future<int> size() async {
    MyImages myImages = await getImages();
    return myImages.length();
  }

  static Future<int> getLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_KEY_NAME_LAST_PAGE) ?? 0;
  }

  static Future<void> setLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_KEY_NAME_LAST_PAGE, page);
  }

}
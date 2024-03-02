
import 'package:image_barcode_collector/entities/pageable.dart';

import '../storages/image_storage.dart';
import 'my_images.dart';

class ImagesOfStorage {

  static final int _loadSizeOfStorage = 12;

  final Pageable _pageable = Pageable(size: _loadSizeOfStorage, page: 0);
  int _count = -1;
  late MyImages _currentImages;

  static Future<ImagesOfStorage> from() async {
    var instance = ImagesOfStorage();
    instance._currentImages = await imageStorage.getImagesByPage(instance._pageable);
    instance._pageable.increasePage();
    instance._count = await imageStorage.size();

    return instance;
  }

  Future<ImagesOfStorage> load() async {
    _currentImages = await imageStorage.getImagesByPage(_pageable);
    _pageable.increasePage();
    return this;
  }

  bool hasNext() {
    return _currentImages.length() == _loadSizeOfStorage;
  }

  MyImages getCurrentImages() {
    return _currentImages;
  }

  bool isLastPage() {
    return 0 < _currentImages.length() &&
        _currentImages.length() < _loadSizeOfStorage;
  }

  bool isInitialized() {
    return _count != -1;
  }

}
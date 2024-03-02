
import 'package:image_barcode_collector/entities/album.dart';
import 'package:image_barcode_collector/entities/pageable.dart';

import '../storages/image_storage.dart';
import '../utils/barcode_processor.dart';
import 'my_images.dart';

class ImagesOfAlbum {


  final Album album;
// 앨범에서 스캔할 파일 수
  static int _loadSizeOfAlbum = 15;
// 앨범에서 가져온 바코드 이미지수가 최소 3개가 되어야 렌더링 된다. 그 이하면 더 불러온다
  static int _minSizeOfRendering = 3;

  final Pageable _pageable = Pageable(size: _loadSizeOfAlbum, page: 0);
  int _count = -1;
  late MyImages _currentImages;

  ImagesOfAlbum(this.album);

  static Future<ImagesOfAlbum> from(Album album) async {
    var instance = ImagesOfAlbum(album);
    instance._count = await album.countAsset();
    return instance;
  }

  Future<ImagesOfAlbum> load(MyImages scannedImageCache) async {
    var loadedImages = await album.getAssetListPaged(_pageable);
    MyImages notScannedImages = loadedImages.filterNotIn(scannedImageCache);
    scannedImageStorage.addImages(loadedImages);

    MyImages result = await BarcodeProcessor.filterBarcodeImages(notScannedImages);
    // 신규로 불러온 이미지는 저장소에 동기화
    if (!result.isEmpty()) {
      await imageStorage.addImages(result);
    }

    _currentImages = result;
    _pageable.increasePage();
    return this;
  }

  bool hasNext() {
    return _currentImages.length() == _loadSizeOfAlbum;
  }

  MyImages getCurrentImages() {
    return _currentImages;
  }

  bool isLastPage() {
    return _currentImages.length() == 0;
  }

  bool isInitialized() {
    return _count != -1;
  }

  bool isRepeat() {
    return _currentImages.length() < _minSizeOfRendering &&
        _pageable.offset() <= (_count - _pageable.size);
  }

  int offset() {
    return _pageable.offset();
  }

  int count() {
    return _count;
  }

}
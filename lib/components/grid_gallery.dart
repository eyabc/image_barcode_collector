import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_barcode_collector/entities/images_of_storage.dart';
import 'package:image_barcode_collector/entities/my_image.dart';
import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:image_barcode_collector/storages/image_storage.dart';
import 'package:image_barcode_collector/utils/barcode_processor.dart';
import 'package:image_barcode_collector/utils/image_loader.dart';
import 'package:image_barcode_collector/views/home.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:photo_manager/photo_manager.dart';

import '../states/image_state.dart';
import '../storages/component_view_storage.dart';
import 'image_item.dart';

class GridGallery extends StatefulWidget {
  const GridGallery({super.key});

  @override
  State<GridGallery> createState() => _GridGallery();
}


// 앨범에서 스캔할 파일 수
const int loadSizeOfElbum = 9;
// 앨범에서 가져온 바코드 이미지수가 최소 3개가 되어야 렌더링 된다. 그 이하면 더 불러온다
const int minSizeOfRendering = 3;

class ImagesFromAlbum {
  final Pageable _pageable = Pageable(size: loadSizeOfElbum, page: 0);
  bool scannedImageLoaded = false;

  Future<MyImages> load(MyImages scannedImageCache) async {
    var loadedImages = await ImageLoader.loadAssetListByPageable(_pageable);

    if (scannedImageCache.isEmpty() && !scannedImageLoaded) {
      // 일급함수가 아님
      scannedImageCache.addMyImages(await scannedImageStorage.getImages());
      scannedImageLoaded = true;
    }

    MyImages notScannedImages = loadedImages.filterNotIn(scannedImageCache);
    MyImages result = await BarcodeProcessor.filterBarcodeImages(notScannedImages);

    scannedImageStorage.addImages(loadedImages);
    _pageable.increasePage();
    // 신규로 불러온 이미지는 저장소에 동기화
    if (!result.isEmpty()) {
      return await imageStorage.addImages(result);
    }

    return MyImages.empty();
  }
}

// todo background reload 와 foregrond 리로드는 storage 가 비었을때만 수행 refresh 는 없애기
class _GridGallery extends State<GridGallery> {
  final PagingController<int, MyImage> _pagingController = PagingController(firstPageKey: 0);
  ImagesOfStorage imagesOfStorage = ImagesOfStorage();
  late ImagesFromAlbum albumImages = ImagesFromAlbum();
  static MyImages scannedImageCache = MyImages.empty();

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) => _load());
    super.initState();
  }

  loadStorageImages() async {
    if (!imagesOfStorage.isInitialized()) {
      imagesOfStorage = await ImagesOfStorage.from();
    }

    /**
     * imagesFromStorage == 0  -> 앨범에서 로드하도록
     * imagesFromStorage == loadSizeOfStorage -> 스토리지에서 더 불러온다.
     * 0 < imagesFromStorage 개수 < loadSizeOfStorage -> 마지막 페이지로 인식하고 앨범에서 로드하도록 한다.
     */
    await imagesOfStorage.load();
    if (imagesOfStorage.hasNext()) {
      append(imagesOfStorage.getCurrentImages(), true);
      return;
    }

    if (imagesOfStorage.isLastPage()) {
      append(imagesOfStorage.getCurrentImages(), true);
    }

  }

  // 과거 이미지 로드기능 추가
  // 신규 이미지 로드기능 보완
  Future<void> _load() async {
    await loadStorageImages();
    if (imagesOfStorage.hasNext()) {
      return;
    }

    MyImages myImagesFromAlbum = await albumImages.load(scannedImageCache);
    while (myImagesFromAlbum.length() < minSizeOfRendering &&
        albumImages._pageable.offset() <= (ImageLoader.getAssetCount() - albumImages._pageable.size)) {
      myImagesFromAlbum.addMyImages(await albumImages.load(scannedImageCache));
      BlocProvider.of<ImageCubit>(context).setTotalLoadingCount(albumImages._pageable.offset());
    }

    if (myImagesFromAlbum.length() == 0) {
      append(myImagesFromAlbum, false);
      BlocProvider.of<ImageCubit>(context).setTotalLoadingCount(ImageLoader.getAssetCount());
      return;
    }

    append(myImagesFromAlbum, true);
  }

  append(MyImages newImages, bool hasNext) {
    final previousItems = _pagingController.value.itemList ?? [];
    final itemList = newImages.addSet(previousItems.toSet());
    _pagingController.value = PagingState<int, MyImage> (
      itemList: itemList.getList(),
      error: null,
      nextPageKey: hasNext ? 1 : null,
    );

  }

  void refresh() async {
    BlocProvider.of<ImageCubit>(context).setTotalLoadingCount(0);
    await ComponentViewStorage.setShowProgressBar(true);
    imagesOfStorage = await ImagesOfStorage.from();
    albumImages = ImagesFromAlbum();
    scannedImageCache = await scannedImageStorage.getImages();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        //새로고침 package안에 들어있는 키워드
        onRefresh: () => Future.sync(refresh),
        //새로고침시 초기화
        child: PagedGridView<int, MyImage>(
          showNewPageProgressIndicatorAsGridChild: false,
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<MyImage>(
            itemBuilder: (context, item, index) => ImageItem(
              myImage: item,
            ),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
        ));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

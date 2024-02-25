import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'image_item.dart';

class GridGallery extends StatefulWidget {
  const GridGallery({super.key});

  @override
  State<GridGallery> createState() => _GridGallery();
}

const int loadSizeOfStorage = 12;

class ImagesFromStorage {
  final Pageable _pageable = Pageable(size: loadSizeOfStorage, page: 0);

  Future<MyImages> load() async {
    MyImages myImages = await imageStorage.getImagesByPage(_pageable);
    _pageable.increasePage();
    return myImages;
  }
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
  late ImagesFromStorage storageImages = ImagesFromStorage();
  late ImagesFromAlbum elbumImages = ImagesFromAlbum();
  static MyImages scannedImageCache = MyImages.empty();

  _GridGallery();

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) => _load());
    super.initState();
  }

  // 과거 이미지 로드기능 추가
  // 신규 이미지 로드기능 보완
  Future<void> _load() async {
    if (await PhotoManager.requestPermissionExtend() != PermissionState.authorized) {
      // todo 권한설정 요청 alert 추가
      _pagingController.appendLastPage([]);
      return;
    }
    /**
     * imagesFromStorage == 0  -> 앨범에서 로드하도록
     * imagesFromStorage == loadSizeOfStorage -> 스토리지에서 더 불러온다.
     * 0 < imagesFromStorage 개수 < loadSizeOfStorage -> 마지막 페이지로 인식하고 앨범에서 로드하도록 한다.
     */
    MyImages imagesFromStorage = await storageImages.load();
    if (imagesFromStorage.length() == loadSizeOfStorage) {
      append(imagesFromStorage, storageImages._pageable);
      return;
    }

    if (0 < imagesFromStorage.length() &&
        imagesFromStorage.length() < loadSizeOfStorage) {
      append(imagesFromStorage, storageImages._pageable);
    }

    MyImages myImagesFromAlbum = await elbumImages.load(scannedImageCache);
    while (myImagesFromAlbum.length() < minSizeOfRendering &&
        elbumImages._pageable.offset() <= (ImageLoader.getAssetCount() - elbumImages._pageable.size)) {
      myImagesFromAlbum.addMyImages(await elbumImages.load(scannedImageCache));
      BlocProvider.of<ImageCubit>(context).setTotalLoadingCount(elbumImages._pageable.offset());
    }

    if (myImagesFromAlbum.length() == 0) {
      append(myImagesFromAlbum, null);
      BlocProvider.of<ImageCubit>(context).setTotalLoadingCount(ImageLoader.getAssetCount());
      return;
    }

    append(myImagesFromAlbum, elbumImages._pageable);
  }

  append(MyImages newImages, Pageable? pageable) {
    final previousItems = _pagingController.value.itemList ?? [];
    final itemList = newImages.addSet(previousItems.toSet());
    _pagingController.value = PagingState<int, MyImage> (
      itemList: itemList.getList(),
      error: null,
      nextPageKey: pageable?.page,
    );

  }

  void refresh() async {
    await HomeRefresher.refresh();
    storageImages = ImagesFromStorage();
    elbumImages = ImagesFromAlbum();
    BlocProvider.of<ImageCubit>(context).setTotalLoadingCount(0);
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

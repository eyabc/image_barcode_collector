import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_barcode_collector/entities/album.dart';
import 'package:image_barcode_collector/entities/album_of_screenshot.dart';
import 'package:image_barcode_collector/entities/images_of_album.dart';
import 'package:image_barcode_collector/entities/images_of_storage.dart';
import 'package:image_barcode_collector/entities/my_image.dart';
import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:image_barcode_collector/storages/image_storage.dart';
import 'package:image_barcode_collector/utils/barcode_processor.dart';
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

// todo background reload 와 foregrond 리로드는 storage 가 비었을때만 수행 refresh 는 없애기
class _GridGallery extends State<GridGallery> {
  final PagingController<int, MyImage> _pagingController = PagingController(firstPageKey: 0);
  static MyImages scannedImageCache = MyImages.empty();
  ImagesOfStorage imagesOfStorage = ImagesOfStorage();
  ImagesOfAlbum imagesOfAlbum = ImagesOfAlbum(Album());

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

  loadAlbumImages() async {
    if (!imagesOfAlbum.isInitialized()) {
      imagesOfAlbum = await ImagesOfAlbum.from(await AlbumOfScreenshot.from());
      scannedImageCache.addMyImages(await scannedImageStorage.getImages());
    }


    await imagesOfAlbum.load(scannedImageCache);
    while (imagesOfAlbum.isRepeat()) {
      await imagesOfAlbum.load(scannedImageCache);
      BlocProvider.of<ImageCubit>(context).setCount(imagesOfAlbum.offset(), imagesOfAlbum.count());
    }

    if (imagesOfAlbum.isLastPage()) {
      append(imagesOfAlbum.getCurrentImages(), false);
      BlocProvider.of<ImageCubit>(context).setCount(imagesOfAlbum.count(), imagesOfAlbum.count());
      return;
    }

    append(imagesOfAlbum.getCurrentImages(), true);
  }

  // 과거 이미지 로드기능 추가
  // 신규 이미지 로드기능 보완
  Future<void> _load() async {
    await loadStorageImages();
    if (imagesOfStorage.hasNext()) {
      return;
    }

    await loadAlbumImages();
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
    BlocProvider.of<ImageCubit>(context).setCount(0, 0);
    await ComponentViewStorage.setShowProgressBar(true);
    imagesOfStorage = await ImagesOfStorage.from();
    scannedImageCache = await scannedImageStorage.getImages();
    imagesOfAlbum = ImagesOfAlbum(Album());
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

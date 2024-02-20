
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_barcode_collector/entities/my_image.dart';
import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:image_barcode_collector/storages/image_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../states/image_state.dart';
import 'image_item.dart';

class GridGallery extends StatefulWidget {
  const GridGallery({super.key });

  @override
  State<GridGallery> createState() => _GridGallery();
}

class _GridGallery extends State<GridGallery> {
  Pageable pageable = Pageable(size: 9, page: -1);
  Pageable pageableOfStorage = Pageable(size: 12, page: 0);

  final PagingController<int, MyImage> _pagingController = //페이지 번호는 int형으로 받겠다
  PagingController(firstPageKey: 0);

  _GridGallery();

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) { //페이지를 가져오는 리스너
      load();
    });

    super.initState();
  }

  Future<void> load() async {
    MyImages myImages = await loadFromStorage();
    if (!myImages.isEmpty()) {
      await _loadImages(myImages, pageableOfStorage, loadFromStorage);
      return;
    }

    await _loadImages(myImages, pageableOfStorage, loadMyImages);

  }


  Future<MyImages> loadFromStorage() async {
    pageableOfStorage.increasePage();
   return await ImageStorage.getImagesByPage(pageableOfStorage);
  }

  Future<MyImages> loadMyImages() async {
    // 새로 파일에서 가져왔을 떄
    var myImages = await MyImages().loadBarcodeImages(pageable);
    BlocProvider.of<ImageCubit>(context).setTotalLoadingCount(pageable.offset());
    pageable.increasePage();
    if (!myImages.isEmpty()) {
      ImageStorage.addImages(myImages);
    }
    return myImages;
  }

  Future<void> _loadImages(MyImages myImages, Pageable pageable, Future<MyImages> Function() loadFunc) async {
    while (myImages.length() < 3 && pageable.offset() <= (1000 - pageable.size)) {
      myImages.addMyImages(await loadFunc());
    }

    if (pageable.offset() >= 1000) {
      _pagingController.appendLastPage(myImages.getList());
      return;
    }

    _pagingController.appendPage(myImages.getList(), pageable.page);
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, MyImage>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<MyImage>(
            itemBuilder: (context, item, index) => ImageItem(
              assetEntity: item.getAssetEntity(),
            ),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
        );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

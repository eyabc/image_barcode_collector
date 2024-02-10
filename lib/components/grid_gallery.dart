import 'package:flutter/material.dart';
import 'package:image_barcode_collector/entities/my_image.dart';
import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/entities/pageable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'image_item.dart';

class GridGallery extends StatefulWidget {
  const GridGallery({super.key});

  @override
  State<GridGallery> createState() => _GridGallery();
}

class _GridGallery extends State<GridGallery> {
  Pageable pageable = Pageable(size: 9, page: 0);
  MyImages myImages = MyImages();

  final PagingController<int, MyImage> _pagingController = //페이지 번호는 int형으로 받겠다
  PagingController(firstPageKey: 0); //처음 페이지 설정

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) { //페이지를 가져오는 리스너
      _loadImages();
    });

    super.initState();
  }

  Future<MyImages> loadMyImages() async {
    var myImage = MyImages();
    await myImage.loadBarcodeImages(pageable);
    pageable.increasePage();
    return myImage;
  }

  Future<void> _loadImages() async {
    MyImages result = await loadMyImages();
    while (result.length() < 3 && pageable.page < 1000) {
      result.addMyImages(await loadMyImages());
    }

    if (pageable.page > 1000) {
      _pagingController.appendLastPage(result.getList());
      return;
    }

    _pagingController.appendPage(result.getList(), pageable.page);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator( //새로고침 package안에 들어있는 키워드
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        //새로고침시 초기화
        child: PagedGridView<int, MyImage>(
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
        )
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

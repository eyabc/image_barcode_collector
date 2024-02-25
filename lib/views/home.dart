import 'package:flutter/material.dart';
import 'package:image_barcode_collector/components/progress_bar.dart';
import 'package:image_barcode_collector/utils/image_loader.dart';
import '../components/grid_gallery.dart';
import '../entities/my_images.dart';
import '../storages/component_view_storage.dart';
import '../storages/image_storage.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Barcodes From The Gallery'),
          centerTitle: true,
          elevation: 0,
        ),
        body: const GridGallery(),
        bottomNavigationBar: const BottomAppBar(
          child: ProgressBar(),
        ));
  }
}

class HomeRefresher {

  static refresh() async {
    imageStorage.sortImagesByCreatedTime();
    await ImageLoader.loadAssetCount();
    ComponentViewStorage.setShowProgressBar(true);
  }

}
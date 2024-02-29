import 'package:flutter/material.dart';
import 'package:image_barcode_collector/components/progress_bar.dart';
import 'package:image_barcode_collector/utils/image_loader.dart';
import 'package:photo_manager/photo_manager.dart';
import '../components/grid_gallery.dart';
import '../storages/component_view_storage.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionState>(
      future: PhotoManager.requestPermissionExtend(),
      builder: (BuildContext context, AsyncSnapshot<PermissionState> snapshot) {
        var isPermitted = snapshot.data == PermissionState.authorized;
        return Scaffold(
            appBar: AppBar(
              title: const Text('Barcodes From The Gallery'),
              centerTitle: true,
              elevation: 0,
            ),
            body: isPermitted ? const GridGallery() : const Text("앱의 사진 접근 권한을 전체로 허용해 주세요.") ,
            bottomNavigationBar: isPermitted ? const BottomAppBar(
              child: ProgressBar(),
            ) : null);
      },
    );
  }
}

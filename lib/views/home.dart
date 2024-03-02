import 'package:flutter/material.dart';
import 'package:image_barcode_collector/components/ad_google_banner.dart';
import 'package:image_barcode_collector/components/progress_bar.dart';
import 'package:photo_manager/photo_manager.dart';
import '../components/grid_gallery.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionState>(
      future: PhotoManager.requestPermissionExtend(),
      builder: (context, snapshot) {
        var scaffold = Scaffold(
            appBar: AppBar(
              title: const Text('Barcodes From The Gallery'),
              centerTitle: true,
              elevation: 0,
            ));

        if (!snapshot.hasData) {
          return scaffold;
        }

        var hasPermission = snapshot.data == PermissionState.authorized;
        return Scaffold(
            appBar: AppBar(
              title: const AdGoogleBanner(),
              centerTitle: true,
              elevation: 0,
            ),
            body: hasPermission ? const GridGallery() : const Text("앱의 사진 접근 권한을 전체로 허용해 주세요.") ,
            bottomNavigationBar: hasPermission ? const BottomAppBar(
              child: ProgressBar(),
            ) : null);
      },
    );
  }
}

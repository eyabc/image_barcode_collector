import 'package:flutter/material.dart';
import 'package:image_barcode_collector/components/progress_bar.dart';
import '../components/grid_gallery.dart';

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

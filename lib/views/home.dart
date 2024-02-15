import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_barcode_collector/components/progress_bar.dart';
import '../components/grid_gallery.dart';
import '../states/image_state.dart';

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
        body: BlocBuilder<ImageCubit, ImageState>(builder: (context, state) {
          return GridGallery(
              onLoadHandler:
                  BlocProvider.of<ImageCubit>(context).setTotalLoadingCount);
        }),
        bottomNavigationBar: const BottomAppBar(
          child: ProgressBar(),
        ));
  }
}

import 'package:flutter/material.dart';
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
      body: const GridGallery()
    );
  }
}

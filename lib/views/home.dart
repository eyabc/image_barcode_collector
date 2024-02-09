import 'package:flutter/material.dart';

import '../components/custom_card.dart';
import '../vision_detector_views/barcode_scanner_view.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomCard('Barcode Scanning', BarcodeScannerView()),
            ],
          ),
        ),
      ),
    );
  }
}

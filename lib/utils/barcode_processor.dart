import 'dart:async';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../entities/my_image.dart';
import '../entities/my_images.dart';

class BarcodeProcessor {
  static const Duration timeoutDuration = Duration(seconds: 1);

  static Future<MyImages> filterBarcodeImages(MyImages images) async {
    var tasks = images.getList().map((myImage) async {
      try {
        var path = await plugin.getFullFile(myImage.getId(), isOrigin: false).timeout(timeoutDuration);
        if (path != null) {
          var inputImage = InputImage.fromFilePath(path);
          var barcodes = await BarcodeScanner().processImage(inputImage);
          if (barcodes.isNotEmpty) {
            return myImage;
          }
        }
      } on TimeoutException {
        print('Error processing barcode for image with id: ${myImage.getId()}');
      }
      return null;
    });

    var list = await Future.wait(tasks);
    return MyImages.fromSet(list.where((image) => image != null).cast<MyImage>().toSet());
  }
}
import 'dart:async';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../entities/my_image.dart';
import '../entities/my_images.dart';

class BarcodeProcessor {
  static const Duration timeoutDuration = Duration(seconds: 1);


  /// 바코드의 존재 여부에 따라 [images]를 필터링합니다.
  ///
  /// 이 메서드는 주어진 [images]의 각 [MyImage]를 처리하여 바코드를 감지하고,
  /// 감지된 바코드가 있는 이미지만 포함된 새로운 [MyImages]를 반환합니다.
  ///
  /// 이미지의 바코드 감지 프로세스가 시간 초과되면 콘솔에 오류 메시지가 출력됩니다.
  ///
  /// 감지된 바코드를 포함한 이미지만 있는 새로운 [MyImages] 인스턴스가 반환됩니다.
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_barcode_collector/entities/my_images.dart';
import 'package:image_barcode_collector/storages/image_storage.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../states/image_state.dart';
import '../storages/component_view_storage.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    int trailing = MyImages.getAssetCount();

    return FutureBuilder<bool?>(
        future: ComponentViewStorage.isShowProgressBar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return snapshot.data ?? false ? BlocConsumer<ImageCubit, ImageState>(
                listener: (context, state) {},
                builder: (context, state) {
                  return LinearPercentIndicator(
                      lineHeight: 20.0,
                      percent: state.imageCount / trailing,
                      center: Text("${state.imageCount} / $trailing"),
                      barRadius: const Radius.circular(5),
                      progressColor: Colors.amberAccent);
                }) : const Text("최근 이미지 스캔 완료");
          }
          return  const Text("");
        }
    );


  }
}

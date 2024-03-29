import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../states/image_state.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImageCubit, ImageState>(
        listener: (context, state) {},
        builder: (context, state) {
          return LinearPercentIndicator(
              lineHeight: 20.0,
              percent: (state.imageCount + state.totalCount == 0) ? 0.0 : state.imageCount / state.totalCount,
              center: Text("${state.imageCount} / ${state.totalCount}"),
              barRadius: const Radius.circular(5),
              progressColor: Colors.amberAccent);
        });
  }
}

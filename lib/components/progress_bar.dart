import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../states/image_state.dart';

class ProgressBar extends StatelessWidget {
  final int trailing = 1000;

  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context) =>
      Center(
        child: BlocConsumer<ImageCubit, ImageState>(
            listener: (context, state) {},
            builder: (context, state) {
              return LinearPercentIndicator(
                  lineHeight: 20.0,
                  percent: state.imageCount / trailing,
                  center: Text("${state.imageCount} / $trailing"),
                  barRadius: const Radius.circular(5),
                  progressColor: Colors.amberAccent
              );
            }
        )
    );

}

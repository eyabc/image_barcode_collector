import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressBar extends StatelessWidget {
  final int leading;
  final int trailing;
  const ProgressBar({super.key, required this.leading, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: new LinearPercentIndicator(
        animation: true,
        animationDuration: 1000,
        lineHeight: 20.0,
        percent: leading / trailing * 100,
        center: Text(leading.toString() + " / " + trailing.toString()),
        barRadius: Radius.circular(5),
        progressColor: Colors.amberAccent,
      ),
    );
  }
}

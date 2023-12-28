import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class ProgressBarComponent extends StatelessWidget {
  const ProgressBarComponent(
      {super.key, required this.percentageNotifier, required this.label, this.progressColor, this.backgroundColor});

  final ValueNotifier<double> percentageNotifier;
  final String label;
  final Color? progressColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SimpleCircularProgressBar(
      progressColors: [progressColor ?? Colors.blueAccent, Colors.greenAccent],
      size: 125,
      animationDuration: 0,
      backColor: backgroundColor ?? const Color(0xFF16262D),
      valueNotifier: percentageNotifier,
      mergeMode: true,
      onGetText: (_) => Text(label),
    );
  }
}

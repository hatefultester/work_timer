import 'package:flutter/widgets.dart';

extension HeroExtension on Widget {
  Widget applyHero(String? tag) {
    if (tag == null) return this;
    return Hero(tag: tag, child: this);
  }
}

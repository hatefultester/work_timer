import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/widgets.dart';

extension TriggerAnimations on Widget {
  Widget triggeredFadeOut(bool trigger, {Duration? duration}) {
    return this.animate(target: trigger ? 1 : 0).fadeOut(duration: duration);
  }
}

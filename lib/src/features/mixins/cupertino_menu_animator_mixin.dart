import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

mixin CupertinoMenuAnimatorMixin on GetxController {
  Animation<Decoration> boxDecorationAnimation(
    Animation<double> animation,
    BuildContext context, {
    Color? backgroundColor,
  }) {
    final DecorationTween tween = DecorationTween(
      begin: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
        boxShadow: const <BoxShadow>[],
        borderRadius: BorderRadius.circular(20.0),
      ),
      end: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
        boxShadow: CupertinoContextMenu.kEndBoxShadow,
        borderRadius: BorderRadius.circular(20.0),
      ),
    );

    return tween.animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          0.0,
          CupertinoContextMenu.animationOpensAt,
        ),
      ),
    );
  }
}

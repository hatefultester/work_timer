import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../extensions/context.dart';

class IOSBottomButtonComponent extends StatelessWidget {
  const IOSBottomButtonComponent({
    required this.label,
    required this.callback,
    super.key,
  });

  final Widget label;
  final ContextCallback callback;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(left: 22, right: 22, bottom: 60),
        child: Column(
          children: [
            CupertinoButton(
              borderRadius: BorderRadius.circular(16),
              color: CupertinoTheme.of(context).primaryColor,
              padding: const EdgeInsets.all(16),
              onPressed: () => callback(context),
              child: AnimatedDefaultTextStyle(
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                  fontSize: 16,
                ),
                duration: kThemeChangeDuration,
                child: Row(
                  children: [
                    const Spacer(),
                    label,
                    const Spacer(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

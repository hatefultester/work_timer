import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:work_timer/src/ui_kit/shared/context.dart';

import '../shared/gap.dart';

class IOSHeaderComponent extends StatelessWidget {
  const IOSHeaderComponent({required this.title, super.key, required this.onMorePressed});

  final ContextCallback onMorePressed;

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          Gap.h16,
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontWeight: FontWeight.w400,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: CupertinoColors.label.resolveFrom(context).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(5, 5),
                ),
              ],
              fontSize: 30,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => onMorePressed(context),
          ),
        ],
      ),
    );
  }
}

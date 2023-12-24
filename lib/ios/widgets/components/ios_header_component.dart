import 'package:flutter/cupertino.dart';

import '../../../shared/ui/gap.dart';

class IOSHeaderComponent extends StatelessWidget {
  const IOSHeaderComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 100,
      child: Row(
        children: [
          const Spacer(),
          Icon(
            CupertinoIcons.timer,
            size: 35,
          ),
          Gap.h16,
          Text(
            'Work tracker',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontWeight: FontWeight.w400,
              letterSpacing: -1,
              fontSize: 35,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

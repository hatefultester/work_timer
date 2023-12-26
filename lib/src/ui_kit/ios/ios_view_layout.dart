import 'package:flutter/cupertino.dart';

class IOSViewLayout extends StatelessWidget {
  const IOSViewLayout({super.key, required this.header, required this.content});

  final Widget header;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          header,
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.resolveFrom(context).withOpacity(0.3),
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

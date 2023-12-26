import 'package:flutter/cupertino.dart';

class IOSBoxComponent extends StatelessWidget {
  const IOSBoxComponent({super.key, required this.items, this.mainAxisAlignment, this.crossAxisAlignment});

  final List<Widget> items;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        minHeight: 200,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items),
    );
  }
}

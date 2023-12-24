import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSViewLayout extends StatelessWidget {
  const IOSViewLayout({super.key, required this.header, required this.content});

  final Widget header;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          header,
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemFill.resolveFrom(context).withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 10, // Use a negative spreadRadius
                    offset: Offset(0, -10),
                  ),
                ],
                color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

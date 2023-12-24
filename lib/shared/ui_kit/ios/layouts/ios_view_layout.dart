import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGroupedBackground.resolveFrom(context).withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 10, // Use a negative spreadRadius
                    offset: Offset(0, -10),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemIndigo.resolveFrom(context),
                    CupertinoColors.systemIndigo.resolveFrom(context).withOpacity(0.85),
                    CupertinoColors.systemGroupedBackground.resolveFrom(context),
                    CupertinoColors.systemBackground.resolveFrom(context),
                  ],
                  stops: [0.2, 0.5, 0.85, 1],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'gap.dart';

class AppIconComponent extends StatelessWidget {
  const AppIconComponent({required this.appVersionNumber, super.key});

  final String appVersionNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(
            maxHeight: 90,
            maxWidth: 90,
          ),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/logo.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        Gap.v8,
        Text(appVersionNumber),
      ],
    );
  }
}

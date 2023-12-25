import 'package:flutter/widgets.dart';

abstract class Gap {
  static SizedBox get v4 => const SizedBox(height: 4);

  static SizedBox get v8 => const SizedBox(height: 8);

  static SizedBox get v16 => const SizedBox(height: 16);

  static SizedBox get v24 => const SizedBox(height: 24);

  static SizedBox get v32 => const SizedBox(height: 32);

  static SizedBox get v40 => const SizedBox(height: 40);

  static SizedBox get v48 => const SizedBox(height: 48);

  static SizedBox get v56 => const SizedBox(height: 56);

  static SizedBox get v64 => const SizedBox(height: 64);

  static SizedBox get h4 => const SizedBox(width: 4);

  static SizedBox get h8 => const SizedBox(width: 8);

  static SizedBox get h16 => const SizedBox(width: 16);

  static SizedBox get h24 => const SizedBox(width: 24);

  static SizedBox get h32 => const SizedBox(width: 32);

  static SizedBox get h40 => const SizedBox(width: 40);

  static SizedBox get h48 => const SizedBox(width: 48);

  static SizedBox get h56 => const SizedBox(width: 56);

  static SizedBox get h64 => const SizedBox(width: 64);
}

abstract class SliverGap {
  static SliverToBoxAdapter get v4 => const SliverToBoxAdapter(child: SizedBox(height: 4));

  static SliverToBoxAdapter get v8 => const SliverToBoxAdapter(child: SizedBox(height: 8));

  static SliverToBoxAdapter get v16 => const SliverToBoxAdapter(child: SizedBox(height: 16));

  static SliverToBoxAdapter get v24 => const SliverToBoxAdapter(child: SizedBox(height: 24));

  static SliverToBoxAdapter get v32 => const SliverToBoxAdapter(child: SizedBox(height: 32));

  static SliverToBoxAdapter get v40 => const SliverToBoxAdapter(child: SizedBox(height: 40));

  static SliverToBoxAdapter get v48 => const SliverToBoxAdapter(child: SizedBox(height: 48));

  static SliverToBoxAdapter get v56 => const SliverToBoxAdapter(child: SizedBox(height: 56));

  static SliverToBoxAdapter get v64 => const SliverToBoxAdapter(child: SizedBox(height: 64));

  static SliverToBoxAdapter get h4 => const SliverToBoxAdapter(child: SizedBox(width: 4));

  static SliverToBoxAdapter get h8 => const SliverToBoxAdapter(child: SizedBox(width: 8));

  static SliverToBoxAdapter get h16 => const SliverToBoxAdapter(child: SizedBox(width: 16));

  static SliverToBoxAdapter get h24 => const SliverToBoxAdapter(child: SizedBox(width: 24));

  static SliverToBoxAdapter get h32 => const SliverToBoxAdapter(child: SizedBox(width: 32));

  static SliverToBoxAdapter get h40 => const SliverToBoxAdapter(child: SizedBox(width: 40));

  static SliverToBoxAdapter get h48 => const SliverToBoxAdapter(child: SizedBox(width: 48));

  static SliverToBoxAdapter get h56 => const SliverToBoxAdapter(child: SizedBox(width: 56));

  static SliverToBoxAdapter get h64 => const SliverToBoxAdapter(child: SizedBox(width: 64));
}

extension GapExtension on Iterable<Widget> {
  Iterable<Widget> interspace(Widget gap) sync* {
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield gap;
        yield iterator.current;
      }
    }
  }
}

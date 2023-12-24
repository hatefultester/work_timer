import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class IOSSlidePageBuilder extends PageRouteBuilder {
  final Widget page;

  IOSSlidePageBuilder({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: 1.seconds,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);
            var opacityTween = Tween(begin: 0.0, end: 1.0);
            var opacityAnimation = animation.drive(opacityTween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: opacityAnimation,
                child: child,
              ),
            );
          },
        );
}

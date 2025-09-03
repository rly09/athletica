import 'package:flutter/material.dart';

class PageTransitions {
  static Route createSlideFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginOffset = Offset(1.0, 0.0);
        const endOffset = Offset.zero;
        const curve = Curves.easeInOut;

        final tween =
        Tween(begin: beginOffset, end: endOffset).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}

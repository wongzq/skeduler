import 'package:flutter/material.dart';

class CustomTransitionRoute extends PageRouteBuilder {
  final Widget page;

  CustomTransitionRoute.fadeScale({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              useFadeTransition(
            animation,
            useScaleTransition(animation, child),
          ),
        );
  CustomTransitionRoute.fadeSlideRight({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              useFadeTransition(
            animation,
            useSlideFromRightTransition(animation, child),
          ),
        );
}

FadeTransition useFadeTransition(Animation<double> animation, Widget child) {
  return FadeTransition(
    opacity: Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ),
    ),
    child: child,
  );
}

ScaleTransition useScaleTransition(Animation<double> animation, Widget child) {
  return ScaleTransition(
    scale: Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ),
    ),
    child: child,
  );
}

SlideTransition useSlideFromRightTransition(
    Animation<double> animation, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}

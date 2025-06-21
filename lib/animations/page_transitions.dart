import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Offset beginOffset;
  final Duration duration;

  SlidePageRoute({
    required this.child,
    this.beginOffset = const Offset(1.0, 0.0),
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var tween = Tween(begin: beginOffset, end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut));
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  FadePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  ScalePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var tween = Tween(begin: 0.8, end: 1.0)
                .chain(CurveTween(curve: Curves.easeInOut));
            
            return ScaleTransition(
              scale: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SlideUpPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

class CustomPageTransitions {
  static Route<T> slideFromRight<T>(Widget child) {
    return SlidePageRoute<T>(
      child: child,
      beginOffset: const Offset(1.0, 0.0),
    );
  }

  static Route<T> slideFromLeft<T>(Widget child) {
    return SlidePageRoute<T>(
      child: child,
      beginOffset: const Offset(-1.0, 0.0),
    );
  }

  static Route<T> slideFromBottom<T>(Widget child) {
    return SlideUpPageRoute<T>(child: child);
  }

  static Route<T> fadeIn<T>(Widget child) {
    return FadePageRoute<T>(child: child);
  }

  static Route<T> scaleIn<T>(Widget child) {
    return ScalePageRoute<T>(child: child);
  }
}

// Extension pour faciliter l'utilisation
extension NavigatorExtensions on NavigatorState {
  Future<T?> pushSlideFromRight<T>(Widget page) {
    return push<T>(CustomPageTransitions.slideFromRight<T>(page));
  }

  Future<T?> pushSlideFromLeft<T>(Widget page) {
    return push<T>(CustomPageTransitions.slideFromLeft<T>(page));
  }

  Future<T?> pushSlideFromBottom<T>(Widget page) {
    return push<T>(CustomPageTransitions.slideFromBottom<T>(page));
  }

  Future<T?> pushFadeIn<T>(Widget page) {
    return push<T>(CustomPageTransitions.fadeIn<T>(page));
  }

  Future<T?> pushScaleIn<T>(Widget page) {
    return push<T>(CustomPageTransitions.scaleIn<T>(page));
  }

  Future<T?> pushReplacementSlideFromRight<T>(Widget page) {
    return pushReplacement<T, dynamic>(
      CustomPageTransitions.slideFromRight<T>(page),
    );
  }

  Future<T?> pushReplacementFadeIn<T>(Widget page) {
    return pushReplacement<T, dynamic>(
      CustomPageTransitions.fadeIn<T>(page),
    );
  }
}

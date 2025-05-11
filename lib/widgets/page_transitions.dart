import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Define the custom curve
const customEaseInOutCurve = Cubic(0.4, 0.0, 0.2, 1.0);

// Duration for all transitions
const transitionDuration = Duration(milliseconds: 300);

CustomTransitionPage buildPageTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Create curved animations
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: customEaseInOutCurve,
        reverseCurve: customEaseInOutCurve,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
    transitionDuration: transitionDuration,
  );
}

// Helper class for other transitions in the app
class AppTransitions {
  static Widget fadeScale({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: customEaseInOutCurve,
        );
        
        return Transform.scale(
          scale: 0.5 + (curvedAnimation.value * 0.5),
          child: Opacity(
            opacity: curvedAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  static Widget slideUp({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: customEaseInOutCurve,
        );
        
        return Transform.translate(
          offset: Offset(0, 20 * (1 - curvedAnimation.value)),
          child: Opacity(
            opacity: curvedAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedPage extends StatelessWidget {
  final Widget child;
  final int index;
  final int selectedIndex;

  const AnimatedPage({
    super.key,
    required this.child,
    required this.index,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Different animations based on navigation direction
    final isForward = index > selectedIndex;
    final offset = isForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

    return child
        .animate(
          target: index == selectedIndex ? 1.0 : 0.0,
        )
        .fadeIn(
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        )
        .slideX(
          begin: offset.dx,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
} 
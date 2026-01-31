import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/nature_background.png'),
              fit: BoxFit.cover,
              opacity: 0.15, // Subtle background
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF1A2416), // Dark forest
                  const Color(0xFF2D5016), // Forest green
                  _controller.value * 0.5, // Less intense animation
                )!,
                const Color(0xFF1A2416), // Dark background
                Color.lerp(
                  const Color(0xFF2D5016), // Forest green
                  const Color(0xFF1A2416), // Dark forest
                  _controller.value * 0.5,
                )!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

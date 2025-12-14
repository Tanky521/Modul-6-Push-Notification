// lib/presentation/widgets/animated/fade_in_widget.dart
import 'package:flutter/material.dart';

class FadeInWidget extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final bool disableAnimation;

  const FadeInWidget({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 0),
    this.disableAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    // Cek apakah animasi dinonaktifkan (hemat daya atau pengguna matikan animasi)
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    
    if (disableAnimation || disableAnimations) {
      return child;
    }

    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child: AnimatedSlide(
              offset: const Offset(0, 0.1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: child,
            ),
          );
        }
        return const SizedBox(); // Tidak tampilkan sebelum delay selesai
      },
    );
  }
}
// lib/presentation/widgets/common/blue_card.dart
import 'package:flutter/material.dart';

class BlueCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const BlueCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: child,
      ),
    );
  }
}
import 'package:flutter/material.dart';

class DebugBuildBadge extends StatelessWidget {
  const DebugBuildBadge({super.key});

  static const String label = 'debug v1 tester';

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xCC0E121B),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

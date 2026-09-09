import 'package:flutter/material.dart';

class AppHeaderProfileAvatar extends StatelessWidget {
  final VoidCallback? onTap;
  final String initials;

  const AppHeaderProfileAvatar({
    super.key,
    this.onTap,
    this.initials = 'AL',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF24487A),
            width: 1.5,
          ),
        ),
        child: CircleAvatar(
          radius: 17,
          backgroundColor: const Color(0xFF24487A),
          child: Text(
            initials.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

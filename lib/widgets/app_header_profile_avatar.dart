import 'package:flutter/material.dart';

class AppHeaderProfileAvatar extends StatelessWidget {
  final VoidCallback? onTap;

  const AppHeaderProfileAvatar({super.key, this.onTap});

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
        child: const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0xFF24487A),
          child: Text(
            'RC',
            style: TextStyle(
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

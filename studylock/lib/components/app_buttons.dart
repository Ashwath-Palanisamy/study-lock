import 'package:flutter/material.dart';

class AppButtons extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Size? size;
  final Color? color;

  const AppButtons({
    super.key,
    required this.child,
    required this.onPressed,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.lightBlueAccent,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: child,
    );

    if (size != null) {
      return SizedBox(width: size!.width, height: size!.height, child: button);
    }

    return SizedBox(width: double.infinity, height: 50, child: button);
  }
}

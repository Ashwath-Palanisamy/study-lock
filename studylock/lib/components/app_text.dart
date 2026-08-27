import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Color? color;

  const AppText(this.text, {super.key, this.style, this.textAlign, this.color});

  const AppText.title(this.text, {super.key, this.textAlign, this.color})
    : style = const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  const AppText.heading(this.text, {super.key, this.textAlign, this.color})
    : style = const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      );

  const AppText.body(this.text, {super.key, this.textAlign, this.color})
    : style = const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.grey,
      );

  @override
  Widget build(BuildContext context) {
  
    final TextStyle baseStyle = style ?? const TextStyle(fontSize: 14, color: Colors.white);
    final TextStyle finalStyle = color != null ? baseStyle.copyWith(color: color) : baseStyle;

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
    );
  }
}
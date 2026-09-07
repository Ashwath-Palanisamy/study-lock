import 'package:flutter/material.dart';

class FocusModeStopAlert extends StatelessWidget {
  const FocusModeStopAlert({
    super.key,
    required this.title,
    required this.content,
    required this.choice1,
    required this.choice2,
  });

  final String title;
  final String content;
  final String choice1;
  final String choice2;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(choice1),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(choice2),
        ),
      ],
    );
  }
}

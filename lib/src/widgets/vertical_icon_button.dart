import 'package:flutter/material.dart';

class VerticalIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final Icon icon;
  final String label;

  const VerticalIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onPressed,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: icon,
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            )
          ],
        ),
      );
}

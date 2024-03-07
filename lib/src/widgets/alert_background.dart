import 'dart:ui';

import 'package:flutter/material.dart';

class AlertBackground extends StatelessWidget {
  const AlertBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: Center(
          child: SizedBox(
            width: 400,
            child: Card(
              color: Colors.white,
              // width: 400,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

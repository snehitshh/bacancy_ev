import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double iconSize;
  final bool showText;
  const AppLogo({Key? key, this.iconSize = 80, this.showText = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.eco,
          color: Colors.green.shade700,
          size: iconSize,
        ),
        if (showText) ...[
          const SizedBox(height: 24),
          Text(
            'Bacancy EV System',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Drive Smarter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ]
      ],
    );
  }
} 
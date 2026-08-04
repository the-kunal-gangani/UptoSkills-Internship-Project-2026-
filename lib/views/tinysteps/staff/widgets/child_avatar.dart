import 'package:flutter/material.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class ChildAvatar extends StatelessWidget {
  final String name;
  final double size;

  const ChildAvatar({
    super.key,
    required this.name,
    this.size = 48,
  });

  String get initials {
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts[0][0];
    return parts[0][0] + parts[1][0];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: context.colors.primaryLight,
      child: Text(
        initials.toUpperCase(),
        style: context.textStyles.labelBold.copyWith(
          color: context.colors.primary,
        ),
      ),
    );
  }
}

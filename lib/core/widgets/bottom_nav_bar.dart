import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class BottomNavBarItem {
  final IconData icon;
  final String label;

  const BottomNavBarItem({
    required this.icon,
    required this.label,
  });
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavBarItem> items;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Get bottom padding to safely extend behind the system navigation bar (e.g., iOS home indicator)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // ColoredBox fills the entire bottomNavigationBar slot with bgLight so
    // the area behind the floating pill doesn't go black on Android.
    return ColoredBox(
      color: context.colors.bgLight,
      child: Container(
        margin: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: bottomPadding > 0 ? bottomPadding + AppSpacing.md : AppSpacing.lg,
          top: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = index == currentIndex;
            final item = items[index];

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? context.colors.primaryLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected ? context.colors.primary : context.colors.textMuted,
                        size: 24,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        item.label,
                        style: context.textStyles.caption.copyWith(
                          color: isSelected ? context.colors.primary : context.colors.textMuted,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

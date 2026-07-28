import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class ActivityDashboardScreen extends StatelessWidget {
  final String childId;
  final String childName;

  const ActivityDashboardScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    final dashboardCards = [
      {
        'title': 'Activity Form',
        'subtitle': 'Daily activity & mood',
        'icon': Icons.directions_run_rounded,
        'route': '/teacher/child/$childId/activity-form',
        'tags': ['Sleep', 'Hydration', 'Mood'],
        'color': context.colors.primary,
      },
      {
        'title': 'Nutrition Form',
        'subtitle': 'Meals & hydration',
        'icon': Icons.restaurant_menu_rounded,
        'route': '/teacher/child/$childId/nutrition-form',
        'tags': ['Meal Intake', 'Meals'],
        'color': context.colors.secondary,
      },
      {
        'title': 'Growth Form',
        'subtitle': 'Weight & height',
        'icon': Icons.show_chart_rounded,
        'route': '/teacher/child/$childId/growth-form',
        'tags': ['Weight', 'Height'],
        'color': const Color(0xFF6C63FF),
      },
      {
        'title': 'Incident Form',
        'subtitle': 'Medical & incidents',
        'icon': Icons.warning_amber_rounded,
        'route': '/teacher/child/$childId/incident-form',
        'tags': ['Reports', 'Attachments'],
        'color': context.colors.danger,
      },
    ];

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Activity', style: context.textStyles.heading2),
            Text(
              childName,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: GridView.builder(
          itemCount: dashboardCards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final card = dashboardCards[index];
            final color = card['color'] as Color;
            final tags = card['tags'] as List<String>;

            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () => context.push(
                card['route'] as String,
                extra: {'childName': childName},
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: context.colors.border),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon badge
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        card['icon'] as IconData,
                        size: 24,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Title
                    Text(
                      card['title'] as String,
                      style: context.textStyles.labelBold.copyWith(
                        color: context.colors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      card['subtitle'] as String,
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: context.textStyles.bodySmall.copyWith(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

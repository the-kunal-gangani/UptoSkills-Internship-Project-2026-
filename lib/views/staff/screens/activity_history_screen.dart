import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tinysteps/Controllers/activity_history_controller.dart';
import 'package:tinysteps/Models/history_entry_model.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class ActivityHistoryScreen extends ConsumerWidget {
  final String childId;
  final String? childName;

  const ActivityHistoryScreen({
    super.key,
    required this.childId,
    this.childName,
  });

  String _formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      return DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return '—';
    }
  }

  Color _colorForType(BuildContext context, FormType type) => switch (type) {
    FormType.activity => context.colors.primary,
    FormType.nutrition => context.colors.secondary,
    FormType.growth => const Color(0xFF6C63FF),
    FormType.incident => context.colors.danger,
  };

  IconData _iconForType(FormType type) => switch (type) {
    FormType.activity => Icons.directions_run_rounded,
    FormType.nutrition => Icons.restaurant_menu_rounded,
    FormType.growth => Icons.show_chart_rounded,
    FormType.incident => Icons.warning_amber_rounded,
  };

  String _labelForType(FormType type) => switch (type) {
    FormType.activity => 'Activity',
    FormType.nutrition => 'Nutrition',
    FormType.growth => 'Growth',
    FormType.incident => 'Incident',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(activityHistoryProvider(childId));
    final activeFilter = ref.watch(activityFilterProvider);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity History', style: context.textStyles.heading2),
            if (childName != null)
              Text(
                childName!,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
          ],
        ),
      ),
      body: historyAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Failed to load history\n$error',
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMuted,
          ),
        ),
        data: (all) {
          final filtered = activeFilter == null
              ? all
              : all.where((e) => e.type == activeFilter).toList();

          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  children: [
                    _FilterChip(
                      label: 'All',
                      icon: Icons.list_rounded,
                      color: context.colors.textDark,
                      isSelected: activeFilter == null,
                      onTap: () =>
                          ref.read(activityFilterProvider.notifier).state =
                              null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ...[
                      FormType.activity,
                      FormType.nutrition,
                      FormType.growth,
                      FormType.incident,
                    ].map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: _FilterChip(
                          label: _labelForType(type),
                          icon: _iconForType(type),
                          color: _colorForType(context, type),
                          isSelected: activeFilter == type,
                          onTap: () =>
                              ref.read(activityFilterProvider.notifier).state =
                                  type,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} record${filtered.length != 1 ? 's' : ''}',
                      style: context.textStyles.bodyMuted,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 56,
                              color: context.colors.textMuted,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No records found',
                              style: context.textStyles.bodyMuted,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final entry = filtered[index];
                          return _EntryCard(
                            entry: entry,
                            color: _colorForType(context, entry.type),
                            icon: _iconForType(entry.type),
                            typeLabel: _labelForType(entry.type),
                            formattedDate: _formatDate(
                              entry.data['created_at'],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : color),
            const SizedBox(width: 5),
            Text(
              label,
              style: context.textStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final HistoryEntry entry;
  final Color color;
  final IconData icon;
  final String typeLabel;
  final String formattedDate;

  const _EntryCard({
    required this.entry,
    required this.color,
    required this.icon,
    required this.typeLabel,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: context.textStyles.labelBold.copyWith(
                        color: context.colors.textDark,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  typeLabel,
                  style: context.textStyles.bodySmall.copyWith(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: context.colors.border, height: 1),
          const SizedBox(height: AppSpacing.md),
          ..._buildFields(context),
        ],
      ),
    );
  }

  List<Widget> _buildFields(BuildContext context) {
    final d = entry.data;
    switch (entry.type) {
      case FormType.activity:
        return [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _chip(
                context,
                Icons.local_activity_rounded,
                'Activity',
                d['activity_name'] ?? '—',
                color,
              ),
              _chip(
                context,
                Icons.bedtime_rounded,
                'Sleep',
                d['sleep_hours'] ?? '—',
                color,
              ),
              _chip(
                context,
                Icons.mood_rounded,
                'Mood',
                d['mood'] ?? '—',
                color,
              ),
            ],
          ),
          if ((d['notes'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _fieldRow(context, 'Notes', d['notes']),
          ],
        ];
      case FormType.nutrition:
        return [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _chip(
                context,
                Icons.restaurant_menu_rounded,
                'Meal',
                d['meal'] ?? '—',
                color,
              ),
              _chip(
                context,
                Icons.water_drop_rounded,
                'Hydration',
                d['hydration'] ?? '—',
                color,
              ),
            ],
          ),
        ];
      case FormType.growth:
        return [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _chip(
                context,
                Icons.monitor_weight_rounded,
                'Weight',
                '${d['weight'] ?? '—'} kg',
                color,
              ),
              _chip(
                context,
                Icons.height_rounded,
                'Height',
                '${d['height'] ?? '—'} cm',
                color,
              ),
            ],
          ),
        ];
      case FormType.incident:
        return [
          _fieldRow(context, 'Title', d['title'] ?? '—'),
          const SizedBox(height: AppSpacing.sm),
          _fieldRow(context, 'Description', d['description'] ?? '—'),
        ];
    }
  }

  Widget _chip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: context.textStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textStyles.bodyMuted),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.textStyles.bodyLarge.copyWith(
            color: context.colors.textDark,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/controllers/admin_children_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class ChildrenOverviewScreen extends ConsumerWidget {
  const ChildrenOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminChildrenProvider);
    final ctrl = ref.read(adminChildrenProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title:
            Text('All Children', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            child: TextField(
              onChanged: ctrl.search,
              style: context.textStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search child name...',
                prefixIcon: Icon(Icons.search,
                    color: context.colors.primary, size: 20),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: ctrl.clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: context.colors.bgSurface,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      BorderSide(color: context.colors.border),
                ),
              ),
            ),
          ),

          // ── List ─────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: context.colors.primary,
              onRefresh: ctrl.loadChildren,
              child: _buildContent(context, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AdminChildrenState state) {
    if (state.isLoading) {
      return Center(
          child: CircularProgressIndicator(
              color: context.colors.primary));
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: context.colors.danger, size: 40),
              const SizedBox(height: AppSpacing.sm),
              Text('Failed to load children',
                  style: context.textStyles.labelBold),
              const SizedBox(height: AppSpacing.xs),
              Text(state.errorMessage!,
                  style: context.textStyles.bodySmall,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (state.allChildren.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care_outlined,
                size: 64,
                color:
                    context.colors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('No children enrolled',
                style: context.textStyles.heading3),
          ],
        ),
      );
    }

    if (state.filteredChildren.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 48, color: context.colors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('No matches found',
                style: context.textStyles.heading3),
            Text('Try a different search term',
                style: context.textStyles.bodyMuted),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      itemCount: state.filteredChildren.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final c = state.filteredChildren[index]
            as Map<String, dynamic>;
        final classroom =
            c['classrooms'] as Map<String, dynamic>?;
        final parent =
            c['parents'] as Map<String, dynamic>?;
        final status = c['status'] as String? ?? 'active';

        final classroomLabel = classroom != null
            ? '${classroom['name']} (${classroom['code']})'
            : 'Unassigned';
        final parentName =
            parent?['full_name'] as String? ?? 'Unknown';

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.colors.border),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: classroom != null
                    ? context.colors.primaryLight
                    : context.colors.warning
                        .withValues(alpha: 0.15),
                child: Text(
                  (c['full_name'] as String? ?? 'C')[0]
                      .toUpperCase(),
                  style: context.textStyles.labelBold.copyWith(
                    color: classroom != null
                        ? context.colors.primary
                        : context.colors.warning,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['full_name'] ?? '—',
                        style: context.textStyles.labelBold),
                    Text('Parent: $parentName',
                        style: context.textStyles.bodySmall),
                    Text(
                      'Classroom: $classroomLabel',
                      style: context.textStyles.caption.copyWith(
                        color: classroom != null
                            ? context.colors.textMuted
                            : context.colors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                label: _statusLabel(status),
                color: _statusColor(context, status),
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(String s) => switch (s) {
        'active' => 'Active',
        'withdrawn' => 'Withdrawn',
        'waitlisted' => 'Waitlisted',
        'graduated' => 'Graduated',
        _ => s,
      };

  Color _statusColor(BuildContext context, String s) =>
      switch (s) {
        'active' => context.colors.success,
        'withdrawn' => context.colors.danger,
        'waitlisted' => context.colors.warning,
        'graduated' => context.colors.secondary,
        _ => context.colors.textMuted,
      };
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: context.textStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/Controllers/parent_children_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class MyChildrenScreen extends ConsumerWidget {
  const MyChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parentChildrenProvider);
    final ctrl = ref.read(parentChildrenProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('My Children', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: ctrl.loadChildren,
        child: _buildBody(context, state),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/parent/children/add');
          if (result == true && context.mounted) {
            ctrl.loadChildren();
          }
        },
        backgroundColor: context.colors.primary,
        child: Icon(Icons.add, color: context.colors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ParentChildrenState state) {
    if (state.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Failed to load children.\nPull down to retry.',
            style: context.textStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.children.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care_rounded,
              size: 64,
              color: context.colors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No children added yet', style: context.textStyles.heading3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap the + button to add your child',
              style: context.textStyles.bodyMuted,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: state.children.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final child = state.children[index] as Map<String, dynamic>;
        final childId = child['id'] as String;
        final name = child['full_name'] as String? ?? 'Child';
        final dob = child['date_of_birth'] as String? ?? '';
        final allergies = child['allergies'] as String? ?? '';
        final group = child['classrooms'] as Map<String, dynamic>?;
        final groupName = group?['name'] as String? ?? 'Unassigned';

        String formattedDob = dob;
        if (dob.isNotEmpty) {
          try {
            final date = DateTime.parse(dob);
            formattedDob = '${date.day} ${_monthName(date.month)} ${date.year}';
          } catch (_) {}
        }

        return _ChildCard(
          childId: childId,
          name: name,
          dob: formattedDob,
          classroom: groupName,
          hasAllergies: allergies.isNotEmpty,
        );
      },
    );
  }

  String _monthName(int month) => const [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month];
}

class _ChildCard extends StatelessWidget {
  final String childId;
  final String name;
  final String dob;
  final String classroom;
  final bool hasAllergies;

  const _ChildCard({
    required this.childId,
    required this.name,
    required this.dob,
    required this.classroom,
    this.hasAllergies = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(
        '/parent/children/$childId?name=${Uri.encodeComponent(name)}',
      ),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: context.colors.primary.withValues(alpha: 0.15),
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(name, style: context.textStyles.labelBold),
                      ),
                      if (hasAllergies) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.warning.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 10,
                                color: context.colors.warning,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Allergy',
                                style: context.textStyles.caption.copyWith(
                                  color: context.colors.warning,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('DOB: $dob', style: context.textStyles.bodyMuted),
                  Text('Group: $classroom', style: context.textStyles.bodySmall),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

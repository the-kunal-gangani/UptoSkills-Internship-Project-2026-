import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/controllers/teacher_classroom_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class MyClassroomScreen extends ConsumerWidget {
  const MyClassroomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherClassroomProvider);
    final ctrl = ref.read(teacherClassroomProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text(
          'My Groups',
          style: context.textStyles.labelBold.copyWith(fontSize: 18),
        ),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: ctrl.loadClassrooms,
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TeacherClassroomState state) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Something went wrong.\nPlease try again.',
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMuted,
          ),
        ),
      );
    }

    if (state.classrooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.meeting_room_outlined,
                size: 72,
                color: context.colors.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No Groups Yet',
                style: context.textStyles.labelBold.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                'You will see your assigned groups here\nonce the admin makes an assignment.',
                textAlign: TextAlign.center,
                style: context.textStyles.bodyMuted,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Your Groups',
            style: context.textStyles.labelBold.copyWith(fontSize: 18),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: state.classrooms.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) =>
                _ClassroomCard(data: state.classrooms[index]),
          ),
        ),
      ],
    );
  }
}

class _ClassroomCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ClassroomCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? 'Unnamed';
    final ageRange = data['age_range'] as String? ?? 'N/A';
    final capacity = data['capacity']?.toString() ?? 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.primaryLight,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.school_rounded, color: context.colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(name, style: context.textStyles.labelBold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.escalator_warning_rounded,
                  label: 'Age Range',
                  value: ageRange,
                ),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(
                  icon: Icons.groups_rounded,
                  label: 'Capacity Limit',
                  value: capacity,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Roster report coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Report'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.colors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Text('$label:', style: context.textStyles.bodyMuted),
        const SizedBox(width: AppSpacing.sm),
        Text(value, style: context.textStyles.labelBold),
      ],
    );
  }
}

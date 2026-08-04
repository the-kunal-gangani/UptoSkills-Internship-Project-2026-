import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../Controllers/parent_approval_controller.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/theme/theme_ext.dart';
import 'parent_details_bottomsheet.dart';

class PendingParentsScreen extends ConsumerWidget {
  const PendingParentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parentApprovalProvider);

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.colors.primary,
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: context.textStyles.bodyMedium,
        ),
      );
    }

    if (state.parents.isEmpty) {
      return Center(
        child: Text(
          "No Pending Parents",
          style: context.textStyles.heading3,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(parentApprovalProvider.notifier)
          .loadPendingParents(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.parents.length,
        itemBuilder: (context, index) {
          final parent = state.parents[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  parent.fullName.isNotEmpty
                      ? parent.fullName[0].toUpperCase()
                      : "P",
                ),
              ),
              title: Text(parent.fullName),
              subtitle: Text(parent.email),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Pending",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ParentDetailsBottomSheet(
                    parent: parent,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
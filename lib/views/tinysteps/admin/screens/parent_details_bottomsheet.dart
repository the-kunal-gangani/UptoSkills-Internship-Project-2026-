import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../Controllers/parent_approval_controller.dart';
import '../../../../Models/parent_approval_model.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/theme/theme_ext.dart';

class ParentDetailsBottomSheet extends ConsumerWidget {
  final ParentApprovalModel parent;

  const ParentDetailsBottomSheet({
    super.key,
    required this.parent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              CircleAvatar(
                radius: 35,
                child: Text(
                  parent.fullName.isNotEmpty
                      ? parent.fullName[0].toUpperCase()
                      : "P",
                ),
              ),

              const SizedBox(height: 15),

              Text(
                parent.fullName,
                style: context.textStyles.heading3,
              ),

              const SizedBox(height: 25),

              _detail(
                "Email",
                parent.email,
              ),

              _detail(
                "Phone",
                parent.phone,
              ),

              _detail(
                "Address",
                parent.address ?? "-",
              ),

              _detail(
                "Status",
                parent.approvalStatus,
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        final ok = await ref
                            .read(parentApprovalProvider.notifier)
                            .approveParent(parent.id);

                        if (context.mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? "Parent Approved"
                                    : "Approval Failed",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text("Reject"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        final ok = await ref
                            .read(parentApprovalProvider.notifier)
                            .rejectParent(parent.id);

                        if (context.mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? "Parent Rejected"
                                    : "Reject Failed",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$title :",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
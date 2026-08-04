import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/Controllers/parent_children_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class AddChildScreen extends ConsumerWidget {
  const AddChildScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parentChildrenProvider);
    final ctrl = ref.read(parentChildrenProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Add Child', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: ctrl.addFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: context.colors.accent.withValues(
                    alpha: 0.15,
                  ),
                  child: Icon(
                    Icons.child_care_rounded,
                    color: context.colors.accent,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  'Tell us about your child',
                  style: context.textStyles.bodyMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Child Details', style: context.textStyles.heading3),
              const SizedBox(height: AppSpacing.md),

              // Full Name
              TextFormField(
                controller: ctrl.nameCtrl,
                style: context.textStyles.bodyLarge,
                textCapitalization: TextCapitalization.words,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Full name is required'
                    : null,
                decoration: _inputDecoration(
                  context,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Date of Birth
              GestureDetector(
                onTap: () => ctrl.pickAddDob(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    style: context.textStyles.bodyLarge,
                    decoration: _inputDecoration(
                      context,
                      label: 'Date of Birth',
                      icon: Icons.cake_outlined,
                    ),
                    controller: TextEditingController(
                      text: state.selectedDob == null
                          ? ''
                          : '${state.selectedDob!.day}/${state.selectedDob!.month}/${state.selectedDob!.year}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Gender
              DropdownButtonFormField<String>(
                key: ValueKey(state.selectedGender),
                initialValue: state.selectedGender,
                decoration: _inputDecoration(
                  context,
                  label: 'Gender',
                  icon: Icons.people_outline,
                ),
                dropdownColor: AppColors.bgSurface,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDark,
                ),
                items: ParentChildrenController.genderOptions
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => ctrl.setSelectedGender(val!),
              ),
              const SizedBox(height: AppSpacing.md),

              // Allergies
              TextFormField(
                controller: ctrl.allergyCtrl,
                style: context.textStyles.bodyLarge,
                decoration: _inputDecoration(
                  context,
                  label: 'Allergies (optional)',
                  icon: Icons.warning_amber_outlined,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Medical Notes
              TextFormField(
                controller: ctrl.medCtrl,
                maxLines: 3,
                style: context.textStyles.bodyLarge,
                decoration: _inputDecoration(
                  context,
                  label: 'Medical Notes (optional)',
                  icon: Icons.medical_information_outlined,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),
              Text(
                'A caregiver will be assigned by admin once you book a session.',
                style: context.textStyles.caption,
              ),
              const SizedBox(height: AppSpacing.xxl),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          if (state.selectedDob == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a date of birth.'),
                              ),
                            );
                            return;
                          }
                          final ok = await ctrl.addChild(context);
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: context.colors.success,
                                content: Text(
                                  '${ctrl.nameCtrl.text.trim().isEmpty ? 'Child' : ctrl.nameCtrl.text.trim()} added successfully!',
                                  style: context.textStyles.bodySmall.copyWith(
                                    color: context.colors.white,
                                  ),
                                ),
                              ),
                            );
                            Navigator.pop(context, true);
                          } else if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: context.colors.danger,
                                content: Text(
                                  'Failed to add child. Please try again.',
                                  style: context.textStyles.bodySmall.copyWith(
                                    color: context.colors.white,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    disabledBackgroundColor: context.colors.primary.withValues(
                      alpha: 0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.buttonRadius,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: state.isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: context.colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Add Child',
                          style: context.textStyles.buttonLabel,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: context.textStyles.labelMedium,
      prefixIcon: Icon(icon, color: context.colors.secondary),
      filled: true,
      fillColor: context.colors.bgSurface,
      border: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: context.colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: context.colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(color: context.colors.primary, width: 2),
      ),
    );
  }
}

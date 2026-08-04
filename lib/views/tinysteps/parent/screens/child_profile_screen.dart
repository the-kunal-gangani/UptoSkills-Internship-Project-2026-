import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/Controllers/parent_children_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class ChildProfileScreen extends ConsumerStatefulWidget {
  final String childId;
  final String childName;

  const ChildProfileScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  ConsumerState<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends ConsumerState<ChildProfileScreen> {
  bool _dataLoaded = false;
  String _classroomName = 'Unassigned';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final ctrl = ref.read(parentChildrenProvider.notifier);
    final data = await ctrl.loadChildDetail(widget.childId);
    if (mounted && data != null) {
      final classroom = data['classrooms'] as Map<String, dynamic>?;
      setState(() {
        _classroomName = classroom?['name'] as String? ?? 'Unassigned';
        _dataLoaded = true;
      });
    } else if (mounted) {
      setState(() => _dataLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parentChildrenProvider);
    final ctrl = ref.read(parentChildrenProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text(widget.childName, style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !_dataLoaded
          ? Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: context.colors.primary.withValues(
                        alpha: 0.15,
                      ),
                      child: Text(
                        widget.childName.isNotEmpty
                            ? widget.childName[0].toUpperCase()
                            : 'C',
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/child/${widget.childId}/insights?name=${Uri.encodeComponent(widget.childName)}'),
                      icon: const Icon(Icons.insights_rounded),
                      label: const Text('View AI Insights'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.primary,
                        side: BorderSide(color: context.colors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text('Child Details', style: context.textStyles.heading3),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: ctrl.editNameCtrl,
                    style: context.textStyles.bodyLarge,
                    decoration: _inputDecoration(
                      context,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  GestureDetector(
                    onTap: () => ctrl.pickEditDob(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: context.textStyles.bodyLarge,
                        decoration: _inputDecoration(
                          context,
                          label: 'Date of Birth',
                          icon: Icons.cake_outlined,
                        ),
                        controller: TextEditingController(
                          text: state.editDob != null
                              ? '${state.editDob!.day}/${state.editDob!.month}/${state.editDob!.year}'
                              : '',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    key: ValueKey(state.editGender),
                    initialValue: state.editGender,
                    decoration: _inputDecoration(
                      context,
                      label: 'Gender',
                      icon: Icons.people_outline,
                    ),
                    items: ParentChildrenController.genderOptions
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => ctrl.setEditGender(val!),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: ctrl.editAllergyCtrl,
                    style: context.textStyles.bodyLarge,
                    decoration: _inputDecoration(
                      context,
                      label: 'Allergies',
                      icon: Icons.warning_amber_outlined,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: ctrl.editMedCtrl,
                    maxLines: 3,
                    style: context.textStyles.bodyLarge,
                    decoration: _inputDecoration(
                      context,
                      label: 'Medical Notes',
                      icon: Icons.medical_information_outlined,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    key: ValueKey(state.bloodGroup),
                    initialValue: state.bloodGroup,
                    decoration: _inputDecoration(
                      context,
                      label: 'Blood Group',
                      icon: Icons.bloodtype_outlined,
                    ),
                    items: ParentChildrenController.bloodGroupOptions
                        .map(
                          (bg) => DropdownMenuItem(
                            value: bg,
                            child: Text(bg.isEmpty ? 'Unknown / Not set' : bg),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => ctrl.setBloodGroup(val ?? ''),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextFormField(
                    controller: ctrl.editAddressCtrl,
                    style: context.textStyles.bodyLarge,
                    maxLines: 2,
                    decoration: _inputDecoration(
                      context,
                      label: 'Home Address',
                      icon: Icons.home_outlined,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.bgMuted,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: context.colors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Group: $_classroomName',
                          style: context.textStyles.labelBold,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Group assignment is managed by admin.',
                    style: context.textStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isSaving
                          ? null
                          : () async {
                              final ok = await ctrl.saveChildChanges(
                                widget.childId,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok ? 'Changes saved!' : 'Failed to save.',
                                    ),
                                    backgroundColor: ok
                                        ? context.colors.success
                                        : context.colors.danger,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        disabledBackgroundColor: context.colors.primary
                            .withValues(alpha: 0.6),
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
                              'Save Changes',
                              style: context.textStyles.buttonLabel,
                            ),
                    ),
                  ),
                ],
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

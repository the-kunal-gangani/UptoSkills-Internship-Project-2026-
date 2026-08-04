import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/controllers/admin_users_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/Views/tinysteps/admin/screens/pending_parents_screen.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _UsersTabView();
  }
}

class _UsersTabView extends ConsumerStatefulWidget {
  const _UsersTabView();

  @override
  ConsumerState<_UsersTabView> createState() => _UsersTabViewState();
}

class _UsersTabViewState extends ConsumerState<_UsersTabView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Add Staff dialog ───────────────────────────────────────────────────────
  Future<void> _showAddStaffDialog(
    BuildContext context,
    AdminUsersController ctrl,
  ) async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final desigCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePass = true;
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: context.colors.bgLight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  color: context.colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('Add Staff', style: context.textStyles.heading3),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  _FormField(
                    controller: nameCtrl,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FormField(
                    controller: emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FormField(
                    controller: phoneCtrl,
                    label: 'Phone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FormField(
                    controller: desigCtrl,
                    label: 'Designation',
                    icon: Icons.badge_outlined,
                    hint: 'e.g. Caregiver, Teacher',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Password field with toggle
                  TextFormField(
                    controller: passCtrl,
                    obscureText: obscurePass,
                    style: context.textStyles.bodyMedium,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.length < 8) return 'Min 8 characters';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: context.textStyles.labelMedium,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: context.colors.primary,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: context.colors.textMuted,
                        ),
                        onPressed: () =>
                            setDialogState(() => obscurePass = !obscurePass),
                      ),
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
                        borderSide: BorderSide(
                          color: context.colors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: context.textStyles.labelBold.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.buttonRadius,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);

                      final ok = await ctrl.createTeacher(
                        fullName: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        designation: desigCtrl.text.trim(),
                        password: passCtrl.text.trim(),
                      );

                      setDialogState(() => isSaving = false);

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Staff account created successfully'
                                  : 'Failed to create staff. Try again.',
                            ),
                            backgroundColor: ok
                                ? context.colors.success
                                : context.colors.danger,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Create Staff', style: context.textStyles.buttonLabel),
            ),
          ],
        ),
      ),
    );

    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    desigCtrl.dispose();
    passCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);
    final ctrl = ref.read(adminUsersProvider.notifier);
    final pendingCount = state.pendingParents.length;
    final isOnStaffTab = _tabController.index == 0;

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Users Management', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: context.textStyles.labelBold,
          unselectedLabelStyle: context.textStyles.labelMedium,
          indicatorColor: context.colors.primary,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.textMuted,
          tabs: [
            const Tab(text: 'Staff'),
            const Tab(text: 'Parents'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pending'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.warning,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: context.textStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      // FAB only shows on the Staff tab
      floatingActionButton: isOnStaffTab
          ? FloatingActionButton.extended(
              onPressed: () => _showAddStaffDialog(context, ctrl),
              backgroundColor: context.colors.primary,
              icon: const Icon(Icons.person_add_outlined, color: Colors.white),
              label: Text(
                'Add Staff',
                style: context.textStyles.labelBold.copyWith(
                  color: Colors.white,
                ),
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTeachersTab(context, state, ctrl),
          _buildParentsTab(context, state, ctrl),
          const PendingParentsScreen(),
        ],
      ),
    );
  }

  // ── Staff tab ──────────────────────────────────────────────────────────────
  Widget _buildTeachersTab(
    BuildContext context,
    AdminUsersState state,
    AdminUsersController ctrl,
  ) {
    if (state.isLoadingTeachers) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }
    if (state.teachers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.group_outlined,
                size: 64,
                color: context.colors.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('No staff yet', style: context.textStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tap "Add Staff" to create the first staff account.',
                style: context.textStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: ctrl.loadTeachers,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          100,
        ),
        itemCount: state.teachers.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final t = state.teachers[index] as Map<String, dynamic>;
          final isApproved = t['is_approved'] == true;
          final isActive = t['is_active'] == true;

          final String statusLabel;
          final Color statusColor;
          if (isApproved && isActive) {
            statusLabel = 'Active';
            statusColor = context.colors.success;
          } else if (!isApproved) {
            statusLabel = 'Pending';
            statusColor = context.colors.warning;
          } else {
            statusLabel = 'Inactive';
            statusColor = context.colors.danger;
          }

          return Card(
            elevation: 0,
            color: context.colors.bgSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: context.colors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              leading: CircleAvatar(
                backgroundColor: context.colors.primaryLight,
                child: Text(
                  (t['full_name'] as String? ?? 'T')[0].toUpperCase(),
                  style: context.textStyles.labelBold.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              title: Text(
                t['full_name'] ?? 'Unknown',
                style: context.textStyles.labelBold,
              ),
              subtitle: Builder(
                builder: (_) {
                  final classroomsData =
                      t['classrooms'] as List<dynamic>? ?? [];
                  final classroomName = classroomsData.isNotEmpty
                      ? classroomsData.first['name'] as String
                      : 'No Group';
                  final parts = <String>[
                    if (t['designation'] != null &&
                        (t['designation'] as String).isNotEmpty)
                      t['designation'] as String,
                    classroomName,
                  ];
                  return Text(
                    parts.isEmpty ? 'No details provided' : parts.join('  ·  '),
                    style: context.textStyles.bodySmall,
                  );
                },
              ),
              trailing: _StatusBadge(label: statusLabel, color: statusColor),
              onTap: () => _showTeacherDetail(context, ref, t, ctrl),
            ),
          );
        },
      ),
    );
  }

  // ── Approved parents tab ───────────────────────────────────────────────────
  Widget _buildParentsTab(
    BuildContext context,
    AdminUsersState state,
    AdminUsersController ctrl,
  ) {
    if (state.isLoadingParents) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }
    if (state.parents.isEmpty) {
      return Center(
        child: Text(
          'No approved parents yet',
          style: context.textStyles.bodyMuted,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: ctrl.loadParents,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        itemCount: state.parents.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final p = state.parents[index] as Map<String, dynamic>;
          final childrenData = p['children'] as List<dynamic>? ?? [];
          final childCount = childrenData.length;

          return Card(
            elevation: 0,
            color: context.colors.bgSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: context.colors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              leading: CircleAvatar(
                backgroundColor: context.colors.secondaryLight,
                child: Text(
                  (p['full_name'] as String? ?? 'P')[0].toUpperCase(),
                  style: context.textStyles.labelBold.copyWith(
                    color: context.colors.secondary,
                  ),
                ),
              ),
              title: Text(
                p['full_name'] ?? 'Unknown',
                style: context.textStyles.labelBold,
              ),
              subtitle: Text(
                '${p['phone'] ?? '—'}  ·  $childCount ${childCount == 1 ? 'child' : 'children'}',
                style: context.textStyles.bodySmall,
              ),
              trailing: _StatusBadge(
                label: p['is_active'] == true ? 'Active' : 'Inactive',
                color: p['is_active'] == true
                    ? context.colors.success
                    : context.colors.danger,
              ),
              onTap: () => _showParentDetail(context, p, ctrl),
            ),
          );
        },
      ),
    );
  }

  // ── Teacher detail dialog ──────────────────────────────────────────────────
  Future<void> _showTeacherDetail(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> teacher,
    AdminUsersController ctrl,
  ) async {
    final classrooms = await ctrl.fetchClassroomsForAssignment();
    if (!context.mounted) return;

    String? selectedClassroomId;
    final name = teacher['full_name'] as String? ?? 'Staff';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'T';
    final staffId = teacher['staff_id'] as String?;
    final designation = teacher['designation'] as String?;
    bool isApproved = teacher['is_approved'] == true;
    bool isActive = teacher['is_active'] == true;

    final classroomsData = teacher['classrooms'] as List<dynamic>? ?? [];
    final currentClassroomName = classroomsData.isNotEmpty
        ? classroomsData.first['name'] as String
        : 'Not Assigned';
    selectedClassroomId = classroomsData.isNotEmpty
        ? classroomsData.first['id'] as String
        : null;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: context.colors.bgLight,
          surfaceTintColor: Colors.transparent,
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: context.colors.primary.withValues(
                    alpha: 0.15,
                  ),
                  child: Text(
                    initial,
                    style: context.textStyles.heading1.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(name, style: context.textStyles.heading3),
                const SizedBox(height: 4),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    _StatusBadge(
                      label: isApproved ? 'Approved' : 'Pending',
                      color: isApproved
                          ? context.colors.success
                          : context.colors.warning,
                    ),
                    _StatusBadge(
                      label: isActive ? 'Active' : 'Inactive',
                      color: isActive
                          ? context.colors.success
                          : context.colors.danger,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      if (designation != null && designation.isNotEmpty) ...[
                        _DetailRow(
                          icon: Icons.badge_outlined,
                          label: 'Designation',
                          value: designation,
                        ),
                        Divider(
                          height: AppSpacing.lg,
                          color: context.colors.border,
                        ),
                      ],
                      if (staffId != null && staffId.isNotEmpty) ...[
                        _DetailRow(
                          icon: Icons.numbers,
                          label: 'Staff ID',
                          value: staffId,
                        ),
                        Divider(
                          height: AppSpacing.lg,
                          color: context.colors.border,
                        ),
                      ],
                      _DetailRow(
                        icon: Icons.meeting_room_outlined,
                        label: 'Group',
                        value: currentClassroomName,
                      ),
                      Divider(
                        height: AppSpacing.lg,
                        color: context.colors.border,
                      ),
                      _DetailRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: teacher['email'] as String? ?? '—',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                if (!isApproved)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colors.success,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonRadius,
                        ),
                      ),
                      onPressed: () async {
                        final ok = await ctrl.approveTeacher(teacher['id']);
                        if (ctx.mounted && ok) {
                          setDialogState(() => isApproved = true);
                          Navigator.pop(ctx);
                        }
                      },
                      label: Text(
                        'Approve',
                        style: context.textStyles.buttonLabel,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.warning,
                        side: BorderSide(color: context.colors.warning),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonRadius,
                        ),
                      ),
                      onPressed: () async {
                        final ok = await ctrl.revokeTeacher(teacher['id']);
                        if (ctx.mounted && ok) {
                          setDialogState(() => isApproved = false);
                          Navigator.pop(ctx);
                        }
                      },
                      label: Text(
                        'Revoke Approval',
                        style: context.textStyles.labelBold.copyWith(
                          color: context.colors.warning,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),

                if (isApproved)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(
                        isActive
                            ? Icons.person_off_outlined
                            : Icons.person_add_alt_1,
                        size: 18,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isActive
                            ? context.colors.danger
                            : context.colors.success,
                        side: BorderSide(
                          color: isActive
                              ? context.colors.danger
                              : context.colors.success,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonRadius,
                        ),
                      ),
                      onPressed: () async {
                        final ok = await ctrl.toggleTeacherActive(
                          teacher['id'],
                          isActive,
                        );
                        if (ctx.mounted && ok) {
                          setDialogState(() => isActive = !isActive);
                          Navigator.pop(ctx);
                        }
                      },
                      label: Text(
                        isActive ? 'Deactivate' : 'Activate',
                        style: context.textStyles.labelBold.copyWith(
                          color: isActive
                              ? context.colors.danger
                              : context.colors.success,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),

                Text('Assign Group', style: context.textStyles.labelBold),
                const SizedBox(height: AppSpacing.sm),
                if (classrooms.isEmpty)
                  Text(
                    'No groups available',
                    style: context.textStyles.bodyMuted,
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    dropdownColor: context.colors.bgSurface,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.colors.bgSurface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.inputRadius,
                        borderSide: BorderSide(color: context.colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.inputRadius,
                        borderSide: BorderSide(color: context.colors.border),
                      ),
                    ),
                    hint: Text(
                      'Select classroom',
                      style: context.textStyles.bodyMuted,
                    ),
                    initialValue: selectedClassroomId,
                    items: classrooms.map((c) {
                      final code = c['code'] as String?;
                      final label = (code != null && code.isNotEmpty)
                          ? '${c['name']} ($code)'
                          : '${c['name']}';
                      return DropdownMenuItem<String>(
                        value: c['id'] as String,
                        child: Text(
                          label,
                          style: context.textStyles.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedClassroomId = val),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colors.secondary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonRadius,
                        ),
                      ),
                      onPressed: selectedClassroomId == null
                          ? null
                          : () async {
                              final ok = await ctrl.assignClassroomToTeacher(
                                teacherId: teacher['id'],
                                classroomId: selectedClassroomId!,
                              );
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok
                                          ? 'Staff assigned successfully'
                                          : 'Assignment failed',
                                    ),
                                    backgroundColor: ok
                                        ? context.colors.success
                                        : context.colors.danger,
                                  ),
                                );
                              }
                            },
                      child: Text(
                        'Confirm Assignment',
                        style: context.textStyles.buttonLabel,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Parent detail dialog ───────────────────────────────────────────────────
  void _showParentDetail(
    BuildContext context,
    Map<String, dynamic> parent,
    AdminUsersController ctrl,
  ) {
    final childrenData = parent['children'] as List<dynamic>? ?? [];
    final childCount = childrenData.length;
    final name = parent['full_name'] as String? ?? 'Parent';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    bool isActive = parent['is_active'] == true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: context.colors.bgLight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: context.colors.secondary.withValues(
                    alpha: 0.15,
                  ),
                  child: Text(
                    initial,
                    style: context.textStyles.heading1.copyWith(
                      color: context.colors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(name, style: context.textStyles.heading3),
                const SizedBox(height: 4),
                _StatusBadge(
                  label: isActive ? 'Active' : 'Inactive',
                  color: isActive
                      ? context.colors.success
                      : context.colors.danger,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: parent['phone'] ?? '—',
                      ),
                      Divider(
                        height: AppSpacing.lg,
                        color: context.colors.border,
                      ),
                      if (parent['relationship_to_child'] != null) ...[
                        _DetailRow(
                          icon: Icons.family_restroom,
                          label: 'Relationship',
                          value: parent['relationship_to_child'] as String,
                        ),
                        Divider(
                          height: AppSpacing.lg,
                          color: context.colors.border,
                        ),
                      ],
                      _DetailRow(
                        icon: Icons.person_outline,
                        label: 'Emergency Contact',
                        value: parent['emergency_contact_name'] ?? '—',
                      ),
                      Divider(
                        height: AppSpacing.lg,
                        color: context.colors.border,
                      ),
                      _DetailRow(
                        icon: Icons.contact_phone_outlined,
                        label: 'Emergency Phone',
                        value: parent['emergency_contact_phone'] ?? '—',
                      ),
                      Divider(
                        height: AppSpacing.lg,
                        color: context.colors.border,
                      ),
                      _DetailRow(
                        icon: Icons.child_care_rounded,
                        label: 'Children Enrolled',
                        value: '$childCount',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(
                      isActive
                          ? Icons.person_off_outlined
                          : Icons.person_add_alt_1,
                      size: 18,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isActive
                          ? context.colors.danger
                          : context.colors.success,
                      side: BorderSide(
                        color: isActive
                            ? context.colors.danger
                            : context.colors.success,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.buttonRadius,
                      ),
                    ),
                    onPressed: () async {
                      final ok = await ctrl.toggleParentActive(
                        parent['id'],
                        isActive,
                      );
                      if (ctx.mounted && ok) {
                        setDialogState(() => isActive = !isActive);
                      }
                    },
                    label: Text(
                      isActive ? 'Deactivate Account' : 'Activate Account',
                      style: context.textStyles.labelBold.copyWith(
                        color: isActive
                            ? context.colors.danger
                            : context.colors.success,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.textMedium,
                  side: BorderSide(color: context.colors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.buttonRadius,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
                child: Text('Close', style: context.textStyles.labelBold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable form field ────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: context.textStyles.bodyMedium,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: context.textStyles.labelMedium,
        prefixIcon: Icon(icon, color: context.colors.primary, size: 20),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: context.textStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.colors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.textStyles.caption),
              Text(value, style: context.textStyles.labelBold),
            ],
          ),
        ),
      ],
    );
  }
}

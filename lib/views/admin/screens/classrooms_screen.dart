import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/Controllers/admin_classroom_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class ClassroomsScreen extends ConsumerWidget {
  const ClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminClassroomsProvider);
    final ctrl = ref.read(adminClassroomsProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Groups',
            style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.confirmation_number_outlined),
            tooltip: 'Referral Codes',
            onPressed: () => _showReferralSheet(context, ref),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showUpsertDialog(context, ref, existing: null),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: ctrl.loadClassrooms,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? Center(
                    child: Text('Error: ${state.errorMessage}'))
                : state.classrooms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.class_outlined,
                                size: 64,
                                color: context.colors.textMuted),
                            const SizedBox(height: AppSpacing.md),
                            Text('No groups yet',
                                style:
                                    context.textStyles.heading3),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.all(AppSpacing.lg),
                        itemCount: state.classrooms.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final c = state.classrooms[index]
                              as Map<String, dynamic>;
                          return _ClassroomListItem(
                            classroom: c,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      _ClassroomDetailScreen(
                                          classroom: c),
                                ),
                              );
                              ctrl.loadClassrooms();
                            },
                            onEdit: () => _showUpsertDialog(
                                context, ref,
                                existing: c),
                            onDelete: () => _confirmDelete(
                                context, ctrl, c['id'] as String),
                          );
                        },
                      ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AdminClassroomsController ctrl,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group?'),
        content: const Text(
            'Children in this group will become unassigned.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: context.colors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ctrl.deleteClassroom(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            ok ? 'Group deleted' : 'Delete failed'),
        backgroundColor:
            ok ? context.colors.danger : context.colors.danger,
      ));
    }
  }

  void _showReferralSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: const _ReferralCodesSheet(),
      ),
    );
  }

  Future<void> _showUpsertDialog(
    BuildContext context,
    WidgetRef ref, {
    required Map<String, dynamic>? existing,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: _UpsertClassroomDialog(existing: existing),
      ),
    );
  }
}

// ── Classroom list item ───────────────────────────────────────────────────────
class _ClassroomListItem extends StatelessWidget {
  final Map<String, dynamic> classroom;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClassroomListItem({
    required this.classroom,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final teacherMap =
        classroom['teachers'] as Map<String, dynamic>?;
    final teacherName =
        teacherMap?['full_name'] as String? ?? 'Unassigned';
    final ageGroup = classroom['age_group'] as String? ?? '—';
    final countList = classroom['children'] as List<dynamic>?;
    final int childCount =
        (countList != null && countList.isNotEmpty)
            ? (countList[0]['count'] as int? ?? 0)
            : 0;
    final int maxCapacity =
        classroom['max_capacity'] as int? ?? 20;
    final double progress =
        maxCapacity > 0 ? childCount / maxCapacity : 0;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: context.colors.secondaryLight,
                child: Text(
                  (classroom['name'] as String? ?? 'C')[0]
                      .toUpperCase(),
                  style: context.textStyles.heading3
                      .copyWith(
                          color: context.colors.secondary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(classroom['name'] ?? '—',
                        style: context.textStyles.labelBold),
                    Text('Age: $ageGroup',
                        style: context.textStyles.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outlined,
                            size: 14,
                            color: teacherMap != null
                                ? context.colors.success
                                : context.colors.textMuted),
                        const SizedBox(width: 4),
                        Text(teacherName,
                            style:
                                context.textStyles.caption),
                        const Spacer(),
                        Text('$childCount / $maxCapacity',
                            style: context.textStyles.caption
                                .copyWith(
                                    fontWeight:
                                        FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            context.colors.divider,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                                progress >= 1.0
                                    ? context.colors.danger
                                    : context.colors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style:
                              TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Upsert dialog ─────────────────────────────────────────────────────────────
class _UpsertClassroomDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;
  const _UpsertClassroomDialog({this.existing});

  @override
  ConsumerState<_UpsertClassroomDialog> createState() =>
      _UpsertClassroomDialogState();
}

class _UpsertClassroomDialogState
    extends ConsumerState<_UpsertClassroomDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _capCtrl;
  String? _selectedTeacherId;
  List<dynamic> _teachers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
        text: widget.existing?['name'] ?? '');
    _codeCtrl = TextEditingController(
        text: widget.existing?['code'] ?? '');
    _ageCtrl = TextEditingController(
        text: widget.existing?['age_group'] ?? '');
    _capCtrl = TextEditingController(
        text:
            (widget.existing?['max_capacity'] ?? 20).toString());
    _selectedTeacherId = widget.existing?['teacher_id'];
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final ctrl =
        ref.read(adminClassroomsProvider.notifier);
    final teachers = await ctrl.fetchActiveTeachers(
      currentTeacherId: _selectedTeacherId,
      existingClassroom: widget.existing,
    );
    if (mounted) setState(() => _teachers = teachers);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);

    final ctrl =
        ref.read(adminClassroomsProvider.notifier);
    final ok = await ctrl.saveClassroom(
      existing: widget.existing,
      name: name,
      code: _codeCtrl.text.trim().isEmpty
          ? null
          : _codeCtrl.text.trim(),
      ageGroup: _ageCtrl.text.trim(),
      maxCapacity:
          int.tryParse(_capCtrl.text.trim()) ?? 20,
      teacherId: _selectedTeacherId,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (ok) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _ageCtrl.dispose();
    _capCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null
          ? 'Create Group'
          : 'Edit Group'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Name *')),
            const SizedBox(height: 8),
            TextField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Code (Optional)')),
            const SizedBox(height: 8),
            TextField(
                controller: _ageCtrl,
                decoration: const InputDecoration(
                    labelText: 'Age Group')),
            const SizedBox(height: 8),
            TextField(
                controller: _capCtrl,
                decoration: const InputDecoration(
                    labelText: 'Max Capacity'),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: context.colors.bgSurface,
              initialValue: _selectedTeacherId,
              hint: const Text('Assign Caregiver'),
              items: [
                const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Unassigned')),
                ..._teachers.map((t) => DropdownMenuItem(
                    value: t['id'] as String,
                    child: Text(t['full_name'])))
              ],
              onChanged: (v) =>
                  setState(() => _selectedTeacherId = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}

// ── Referral codes sheet ──────────────────────────────────────────────────────
class _ReferralCodesSheet extends ConsumerStatefulWidget {
  const _ReferralCodesSheet();

  @override
  ConsumerState<_ReferralCodesSheet> createState() =>
      _ReferralCodesSheetState();
}

class _ReferralCodesSheetState
    extends ConsumerState<_ReferralCodesSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(adminClassroomsProvider.notifier)
          .loadReferralCodes();
    });
  }

  void _generateCode() async {
    String selectedRole = 'parent';
    DateTime expiry =
        DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Generate Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: context.colors.bgSurface,
                initialValue: selectedRole,
                items: ['parent', 'teacher', 'admin']
                    .map((r) => DropdownMenuItem(
                        value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) =>
                    setS(() => selectedRole = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Expiry Date'),
                subtitle: Text(expiry
                    .toLocal()
                    .toString()
                    .split(' ')[0]),
                trailing:
                    const Icon(Icons.calendar_today),
                onTap: () async {
                  final p = await showDatePicker(
                    context: context,
                    initialDate: expiry,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now()
                        .add(const Duration(days: 365)),
                  );
                  if (p != null) setS(() => expiry = p);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final ok = await ref
                    .read(adminClassroomsProvider.notifier)
                    .generateReferralCode(
                      role: selectedRole,
                      expiry: expiry,
                    );
                if (ctx.mounted && ok) Navigator.pop(ctx);
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminClassroomsProvider);

    return Container(
      decoration: BoxDecoration(
          color: context.colors.bgLight,
          borderRadius: AppRadius.sheetRadius),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          MediaQuery.of(context).viewInsets.bottom +
              AppSpacing.md),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text('Referral Codes',
                  style: context.textStyles.heading2),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: _generateCode,
            icon: const Icon(Icons.add),
            label: const Text('New Code'),
            style: FilledButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, 50)),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: state.isLoadingCodes
                ? const Center(
                    child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount:
                        state.referralCodes.length,
                    itemBuilder: (context, i) {
                      final item = state.referralCodes[i];
                      final bool isUsed =
                          item['is_used'] ?? false;
                      final bool isExpired =
                          DateTime.parse(item['expires_at'])
                              .isBefore(DateTime.now());
                      final status = isUsed
                          ? 'Used'
                          : (isExpired
                              ? 'Expired'
                              : 'Active');
                      final color = isUsed
                          ? context.colors.info
                          : (isExpired
                              ? context.colors.danger
                              : context.colors.success);

                      return ListTile(
                        title: Text(item['code'],
                            style:
                                context.textStyles.labelBold),
                        subtitle: Text(
                            'Role: ${item['role']} • Exp: ${item['expires_at'].split('T')[0]}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(
                                    alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                              child: Text(status,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 12)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy,
                                  size: 20),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(
                                        text: item['code']));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Copied')));
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Classroom detail screen ───────────────────────────────────────────────────
class _ClassroomDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> classroom;
  const _ClassroomDetailScreen({required this.classroom});

  @override
  ConsumerState<_ClassroomDetailScreen> createState() =>
      _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState
    extends ConsumerState<_ClassroomDetailScreen> {
  late Map<String, dynamic> _current;
  List<dynamic> _children = [];
  List<dynamic> _unassigned = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _current = Map.from(widget.classroom);
    _refresh(silent: false);
  }

  Future<void> _refresh({bool silent = true}) async {
    if (!silent) setState(() => _isLoading = true);
    final ctrl =
        ref.read(adminClassroomsProvider.notifier);
    final updated =
        await ctrl.fetchClassroomDetail(_current['id']);
    final children =
        await ctrl.fetchClassroomChildren(_current['id']);
    final unassigned = await ctrl.fetchUnassignedChildren();
    if (mounted) {
      setState(() {
        if (updated != null) _current = updated;
        _children = children;
        _unassigned = unassigned;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteClassroom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group?'),
        content: const Text(
            'Children in this group will become unassigned.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: context.colors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ref
        .read(adminClassroomsProvider.notifier)
        .deleteClassroom(_current['id']);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            ok ? 'Group deleted' : 'Delete failed'),
        backgroundColor: context.colors.danger,
      ));
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherName =
        _current['teachers']?['full_name'] ?? 'Unassigned';
    return Scaffold(
      appBar: AppBar(
        title: Text(_current['name'] ?? 'Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => UncontrolledProviderScope(
                  container:
                      ProviderScope.containerOf(context),
                  child: _UpsertClassroomDialog(
                      existing: _current),
                ),
              );
              _refresh(silent: true);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete,
                color: context.colors.danger),
            onPressed: _deleteClassroom,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _info('Age Group',
                              _current['age_group'] ?? 'N/A'),
                          const Divider(),
                          _info(
                              'Capacity',
                              '${_children.length} / ${_current['max_capacity'] ?? 20}'),
                          const Divider(),
                          _info('Caregiver', teacherName),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Children (${_children.length})',
                      style: context.textStyles.heading3),
                  ..._children.map(
                      (c) => _childRow(c, isAssigned: true)),
                  if (_unassigned.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                        'Unassigned (${_unassigned.length})',
                        style: context.textStyles.heading3),
                    ..._unassigned.map((c) =>
                        _childRow(c, isAssigned: false)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _info(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: context.textStyles.bodyMuted),
            Text(v, style: context.textStyles.labelBold),
          ],
        ),
      );

  Widget _childRow(dynamic c, {required bool isAssigned}) {
    final ctrl =
        ref.read(adminClassroomsProvider.notifier);
    return ListTile(
      title: Text(c['full_name'] ?? 'Unknown'),
      leading: const CircleAvatar(
          child: Icon(Icons.child_care, size: 18)),
      trailing: isAssigned
          ? IconButton(
              icon: Icon(Icons.remove_circle_outline,
                  color: context.colors.danger),
              onPressed: () async {
                await ctrl
                    .removeChildFromClassroom(c['id']);
                _refresh(silent: true);
              })
          : FilledButton(
              onPressed: () async {
                await ctrl.assignChildToClassroom(
                  childId: c['id'],
                  classroomId: _current['id'],
                  teacherId: _current['teacher_id'],
                );
                _refresh(silent: true);
              },
              child: const Text('Assign')),
    );
  }
}
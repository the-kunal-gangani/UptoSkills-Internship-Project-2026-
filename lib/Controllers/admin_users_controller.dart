import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class AdminUsersState {
  final bool isLoadingTeachers;
  final bool isLoadingParents;
  final bool isLoadingPendingParents;
  final List<dynamic> teachers;
  final List<dynamic> parents;
  final List<dynamic> pendingParents;
  final String? errorMessage;
  final bool isLoadingAdmins;
  final List<dynamic> admins;

  const AdminUsersState({
    this.isLoadingTeachers = true,
    this.isLoadingParents = true,
    this.isLoadingPendingParents = true,
    this.teachers = const [],
    this.parents = const [],
    this.pendingParents = const [],
    this.errorMessage,
    this.isLoadingAdmins = true,
    this.admins = const [],
  });

  AdminUsersState copyWith({
    bool? isLoadingTeachers,
    bool? isLoadingParents,
    bool? isLoadingPendingParents,
    List<dynamic>? teachers,
    List<dynamic>? parents,
    List<dynamic>? pendingParents,
    String? errorMessage,
    bool clearError = false,
    bool? isLoadingAdmins,
    List<dynamic>? admins,
  }) {
    return AdminUsersState(
      isLoadingTeachers: isLoadingTeachers ?? this.isLoadingTeachers,
      isLoadingParents: isLoadingParents ?? this.isLoadingParents,
      isLoadingPendingParents:
          isLoadingPendingParents ?? this.isLoadingPendingParents,
      teachers: teachers ?? this.teachers,
      parents: parents ?? this.parents,
      pendingParents: pendingParents ?? this.pendingParents,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isLoadingAdmins: isLoadingAdmins ?? this.isLoadingAdmins,
      admins: admins ?? this.admins,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class AdminUsersController extends StateNotifier<AdminUsersState> {
  AdminUsersController() : super(const AdminUsersState()) {
    loadTeachers();
    loadParents();
    loadPendingParents();
    loadAdmins();
  }

  final _client = Supabase.instance.client;

  // ── Load teachers ──────────────────────────────────────────────────────────
  Future<void> loadTeachers() async {
    state = state.copyWith(isLoadingTeachers: true, clearError: true);
    try {
      final data = await _client
          .from('teachers')
          .select(
            'id, full_name, email, staff_id, designation, '
            'is_approved, is_active, '
            'classrooms!classrooms_teacher_id_fkey(id, name)',
          )
          .order('full_name');
      state = state.copyWith(isLoadingTeachers: false, teachers: data);
    } catch (e) {
      state = state.copyWith(
        isLoadingTeachers: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadAdmins() async {
    state = state.copyWith(isLoadingAdmins: true, clearError: true);

    try {
      final data = await _client.from('admins').select().order('full_name');

      state = state.copyWith(isLoadingAdmins: false, admins: data);
    } catch (e) {
      state = state.copyWith(
        isLoadingAdmins: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createAdmin({
    required String fullName,
    required String email,
    required String phone,
    required String centerName,
    required String designation,
    required String password,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'create-admin',
        body: {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'center_name': centerName,
          'designation': designation,
          'password': password,
        },
      );

      final data = response.data;

      if (data != null && data['success'] == true) {
        await loadAdmins();
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> toggleAdminActive(String adminId, bool currentValue) async {
    try {
      await _client
          .from('admins')
          .update({'is_active': !currentValue})
          .eq('id', adminId);

      await loadAdmins();

      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Load approved parents ──────────────────────────────────────────────────
  Future<void> loadParents() async {
    state = state.copyWith(isLoadingParents: true, clearError: true);
    try {
      final data = await _client
          .from('parents')
          .select(
            'id, full_name, phone, emergency_contact_name, '
            'emergency_contact_phone, relationship_to_child, '
            'is_active, approval_status, '
            'children!children_parent_id_fkey(id)',
          )
          .eq('approval_status', 'approved')
          .order('full_name');
      state = state.copyWith(isLoadingParents: false, parents: data);
    } catch (e) {
      state = state.copyWith(
        isLoadingParents: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createTeacher({
    required String fullName,
    required String email,
    required String phone,
    required String designation,
    required String password,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'create-teacher',
        body: {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'designation': designation,
          'password': password,
        },
      );

      final data = response.data;

      if (data == null) {
        return false;
      }

      if (data['success'] == true) {
        await loadTeachers();
        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  // ── Load pending parents ───────────────────────────────────────────────────
  Future<void> loadPendingParents() async {
    state = state.copyWith(isLoadingPendingParents: true, clearError: true);
    try {
      final data = await _client
          .from('parents')
          .select(
            'id, full_name, email, phone, '
            'relationship_to_child, approval_status, '
            'children!children_parent_id_fkey(id)',
          )
          .eq('approval_status', 'pending')
          .order('full_name');
      state = state.copyWith(
        isLoadingPendingParents: false,
        pendingParents: data,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingPendingParents: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      loadTeachers(),
      loadParents(),
      loadPendingParents(),
      loadAdmins(),
    ]);
  }

  Future<List<dynamic>> fetchClassroomsForAssignment() async {
    try {
      return await _client
          .from('classrooms')
          .select('id, name, code')
          .order('name');
    } catch (_) {
      return [];
    }
  }

  // ── Teacher actions ────────────────────────────────────────────────────────
  Future<bool> approveTeacher(String teacherId) async {
    try {
      await _client
          .from('teachers')
          .update({'is_approved': true, 'is_active': true})
          .eq('id', teacherId);
      await loadTeachers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> revokeTeacher(String teacherId) async {
    try {
      await _client
          .from('teachers')
          .update({'is_approved': false})
          .eq('id', teacherId);
      await loadTeachers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleTeacherActive(String teacherId, bool currentValue) async {
    try {
      await _client
          .from('teachers')
          .update({'is_active': !currentValue})
          .eq('id', teacherId);
      await loadTeachers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> assignClassroomToTeacher({
    required String teacherId,
    required String classroomId,
  }) async {
    try {
      await _client
          .from('classrooms')
          .update({'teacher_id': teacherId})
          .eq('id', classroomId);
      await _client
          .from('children')
          .update({'teacher_id': teacherId})
          .eq('classroom_id', classroomId);
      await loadTeachers();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Parent approval actions ────────────────────────────────────────────────
  Future<bool> approveParent(String parentId) async {
    try {
      final adminId = _client.auth.currentUser?.id;
      await _client
          .from('parents')
          .update({
            'approval_status': 'approved',
            'approved_by': adminId,
            'approved_at': DateTime.now().toUtc().toIso8601String(),
            'is_active': true,
          })
          .eq('id', parentId);
      await _client.from('notifications').insert({
        'user_id': parentId,
        'title': 'Account Approved',
        'message':
            'Your account has been approved. You can now access TinySteps.',
        'type': 'approval',
        'is_read': false,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      await _client.from('notifications').insert({
        'user_id': parentId,
        'title': 'Account Approved',
        'message':
            'Your account has been approved. You can now access TinySteps.',
        'type': 'parent_approved',
        'is_read': false,
      });
      // Refresh both lists so the parent moves from Pending → Parents tab
      await Future.wait([loadParents(), loadPendingParents()]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectParent(String parentId) async {
    try {
      await _client
          .from('parents')
          .update({'approval_status': 'rejected', 'is_active': false})
          .eq('id', parentId);

      await _client.from('notifications').insert({
        'user_id': parentId,
        'title': 'Account Rejected',
        'message':
            'Your account registration has been rejected. Please contact daycare administration.',
        'type': 'parent_rejected',
        'is_read': false,
      });

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // ── Active toggle for already-approved parents ─────────────────────────────
  Future<bool> toggleParentActive(String parentId, bool currentValue) async {
    try {
      await _client
          .from('parents')
          .update({'is_active': !currentValue})
          .eq('id', parentId);
      await loadParents();
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final adminUsersProvider =
    StateNotifierProvider<AdminUsersController, AdminUsersState>(
      (ref) => AdminUsersController(),
    );

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class AdminClassroomsState {
  final bool isLoading;
  final List<dynamic> classrooms;
  final List<dynamic> referralCodes;
  final bool isLoadingCodes;
  final String? errorMessage;

  const AdminClassroomsState({
    this.isLoading = true,
    this.classrooms = const [],
    this.referralCodes = const [],
    this.isLoadingCodes = false,
    this.errorMessage,
  });

  AdminClassroomsState copyWith({
    bool? isLoading,
    List<dynamic>? classrooms,
    List<dynamic>? referralCodes,
    bool? isLoadingCodes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminClassroomsState(
      isLoading: isLoading ?? this.isLoading,
      classrooms: classrooms ?? this.classrooms,
      referralCodes: referralCodes ?? this.referralCodes,
      isLoadingCodes: isLoadingCodes ?? this.isLoadingCodes,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class AdminClassroomsController extends StateNotifier<AdminClassroomsState> {
  AdminClassroomsController() : super(const AdminClassroomsState()) {
    loadClassrooms();
  }

  final _client = Supabase.instance.client;

  Future<void> loadClassrooms() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _client
          .from('classrooms')
          .select(
            'id, name, code, age_group, max_capacity, teacher_id, '
            'teachers!classrooms_teacher_id_fkey(id, full_name), '
            'children(count)',
          )
          .order('name');
      state = state.copyWith(isLoading: false, classrooms: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadReferralCodes() async {
    state = state.copyWith(isLoadingCodes: true);
    try {
      final data = await _client
          .from('referral_codes')
          .select()
          .order('created_at', ascending: false);
      state = state.copyWith(isLoadingCodes: false, referralCodes: data);
    } catch (_) {
      state = state.copyWith(isLoadingCodes: false);
    }
  }

  Future<List<dynamic>> fetchActiveTeachers({
    String? currentTeacherId,
    Map<String, dynamic>? existingClassroom,
  }) async {
    try {
      final data = await _client
          .from('teachers')
          .select('id, full_name')
          .eq('is_approved', true)
          .eq('is_active', true)
          .order('full_name');

      final teachers = List<dynamic>.from(data);
      if (currentTeacherId != null &&
          !teachers.any((t) => t['id'] == currentTeacherId)) {
        final name =
            existingClassroom?['teachers']?['full_name'] ?? 'Current Teacher';
        teachers.insert(0, {
          'id': currentTeacherId,
          'full_name': '$name (Inactive)',
        });
      }
      return teachers;
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveClassroom({
    Map<String, dynamic>? existing,
    required String name,
    required String? code,
    required String ageGroup,
    required int maxCapacity,
    required String? teacherId,
  }) async {
    final data = {
      'name': name,
      'code': (code == null || code.isEmpty) ? null : code.toUpperCase(),
      'age_group': ageGroup,
      'max_capacity': maxCapacity,
      'teacher_id': teacherId,
    };

    try {
      if (existing != null) {
        final id = existing['id'] as String;
        await _client.from('classrooms').update(data).eq('id', id);
        await _client
            .from('children')
            .update({'teacher_id': teacherId})
            .eq('classroom_id', id);
      } else {
        await _client.from('classrooms').insert(data);
      }
      await loadClassrooms();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteClassroom(String id) async {
    try {
      await _client
          .from('children')
          .update({'classroom_id': null, 'teacher_id': null})
          .eq('classroom_id', id);
      await _client.from('classrooms').delete().eq('id', id);
      await loadClassrooms();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> generateReferralCode({
    required String role,
    required DateTime expiry,
  }) async {
    try {
      final code = 'TINY-${Random().nextInt(9000) + 1000}';
      await _client.from('referral_codes').insert({
        'code': code,
        'role': role,
        'expires_at': expiry.toIso8601String(),
        'created_by': _client.auth.currentUser?.id,
      });
      await loadReferralCodes();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Classroom detail actions ────────────────────────────────────
  Future<Map<String, dynamic>?> fetchClassroomDetail(String id) async {
    try {
      return await _client
          .from('classrooms')
          .select('*, teachers!classrooms_teacher_id_fkey(id, full_name)')
          .eq('id', id)
          .single();
    } catch (_) {
      return null;
    }
  }

  Future<List<dynamic>> fetchClassroomChildren(String classroomId) async {
    try {
      return await _client
          .from('children')
          .select('*')
          .eq('classroom_id', classroomId);
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> fetchUnassignedChildren() async {
    try {
      return await _client
          .from('children')
          .select('*')
          .isFilter('classroom_id', null);
    } catch (_) {
      return [];
    }
  }

  Future<void> removeChildFromClassroom(String childId) async {
    await _client
        .from('children')
        .update({'classroom_id': null, 'teacher_id': null})
        .eq('id', childId);
  }

  Future<void> assignChildToClassroom({
    required String childId,
    required String classroomId,
    required String? teacherId,
  }) async {
    await _client
        .from('children')
        .update({'classroom_id': classroomId, 'teacher_id': teacherId})
        .eq('id', childId);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final adminClassroomsProvider =
    StateNotifierProvider<AdminClassroomsController, AdminClassroomsState>(
      (ref) => AdminClassroomsController(),
    );

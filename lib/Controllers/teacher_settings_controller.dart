import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class TeacherSettingsState {
  final bool isLoading;
  final bool isSaving;
  final String fullName;
  final String email;
  final String phone;
  final String staffId;
  final String designation;
  final String joiningDate;
  final bool isApproved;
  final String? errorMessage;

  const TeacherSettingsState({
    this.isLoading = true,
    this.isSaving = false,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.staffId = '',
    this.designation = '',
    this.joiningDate = '',
    this.isApproved = false,
    this.errorMessage,
  });

  TeacherSettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? fullName,
    String? email,
    String? phone,
    String? staffId,
    String? designation,
    String? joiningDate,
    bool? isApproved,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TeacherSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      staffId: staffId ?? this.staffId,
      designation: designation ?? this.designation,
      joiningDate: joiningDate ?? this.joiningDate,
      isApproved: isApproved ?? this.isApproved,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class TeacherSettingsController
    extends StateNotifier<TeacherSettingsState> {
  TeacherSettingsController()
      : super(const TeacherSettingsState()) {
    loadProfile();
  }

  final _client = Supabase.instance.client;

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final data = await _client
          .from('teachers')
          .select(
              'full_name, email, phone, staff_id, '
              'designation, joining_date, is_approved')
          .eq('id', uid)
          .maybeSingle();

      if (data != null) {
        state = state.copyWith(
          isLoading: false,
          fullName: data['full_name'] as String? ?? '',
          email: data['email'] as String? ??
              _client.auth.currentUser?.email ??
              '',
          phone: data['phone'] as String? ?? '',
          staffId: data['staff_id'] as String? ?? '',
          designation:
              data['designation'] as String? ?? 'Staff',
          joiningDate:
              data['joining_date'] as String? ?? '',
          isApproved: data['is_approved'] == true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          email: _client.auth.currentUser?.email ?? '',
        );
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        email: _client.auth.currentUser?.email ?? '',
      );
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return false;
      await _client.from('teachers').update({
        'full_name': fullName,
        'phone': phone,
      }).eq('id', uid);
      await loadProfile();
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final teacherSettingsProvider = StateNotifierProvider<
    TeacherSettingsController, TeacherSettingsState>(
  (ref) => TeacherSettingsController(),
);
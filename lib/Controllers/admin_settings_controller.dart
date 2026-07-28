import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class AdminSettingsState {
  final bool isLoading;
  final bool isSaving;
  final String fullName;
  final String email;
  final String phone;
  final String designation;
  final String centerName;
  final String? errorMessage;

  const AdminSettingsState({
    this.isLoading = true,
    this.isSaving = false,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.designation = '',
    this.centerName = '',
    this.errorMessage,
  });

  AdminSettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? fullName,
    String? email,
    String? phone,
    String? designation,
    String? centerName,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      designation: designation ?? this.designation,
      centerName: centerName ?? this.centerName,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class AdminSettingsController extends StateNotifier<AdminSettingsState> {
  AdminSettingsController() : super(const AdminSettingsState()) {
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
          .from('admins')
          .select('full_name, email, phone, designation, center_name')
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
          designation: data['designation'] as String? ?? 'Administrator',
          centerName: data['center_name'] as String? ?? '',
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
    required String designation,
    required String centerName,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return false;
      await _client.from('admins').update({
        'full_name': fullName,
        'phone': phone,
        'designation': designation,
        'center_name': centerName,
      }).eq('id', uid);
      await loadProfile();
      return true;
    } catch (e) {
      state = state.copyWith(
          isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final adminSettingsProvider =
    StateNotifierProvider<AdminSettingsController, AdminSettingsState>(
  (ref) => AdminSettingsController(),
);
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class ParentProfileState {
  final bool isLoading;
  final bool isSaving;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String relationship;
  final int childrenCount;
  final String? errorMessage;

  const ParentProfileState({
    this.isLoading = true,
    this.isSaving = false,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.relationship = '',
    this.childrenCount = 0,
    this.errorMessage,
  });

  ParentProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? relationship,
    int? childrenCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ParentProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      relationship: relationship ?? this.relationship,
      childrenCount: childrenCount ?? this.childrenCount,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class ParentProfileController extends StateNotifier<ParentProfileState> {
  ParentProfileController() : super(const ParentProfileState()) {
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
          .from('parents')
          .select(
            'full_name, email, phone, address, '
            'emergency_contact_name, emergency_contact_phone, '
            'relationship_to_child, '
            'children!children_parent_id_fkey(id)',
          )
          .eq('id', uid)
          .maybeSingle();

      if (data != null) {
        final childrenList = data['children'] as List<dynamic>? ?? [];
        state = state.copyWith(
          isLoading: false,
          fullName: data['full_name'] as String? ?? '',
          email:
              data['email'] as String? ?? _client.auth.currentUser?.email ?? '',
          phone: data['phone'] as String? ?? '',
          address: data['address'] as String? ?? '',
          emergencyContactName: data['emergency_contact_name'] as String? ?? '',
          emergencyContactPhone:
              data['emergency_contact_phone'] as String? ?? '',
          relationship: data['relationship_to_child'] as String? ?? '',
          childrenCount: childrenList.length,
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
    required String address,
    required String relationship,
    required String emergencyContactName,
    required String emergencyContactPhone,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return false;

      await _client
          .from('parents')
          .update({
            'full_name': fullName,
            'phone': phone,
            'address': address.trim().isEmpty ? null : address,
            'relationship_to_child': relationship,
            'emergency_contact_name': emergencyContactName,
            'emergency_contact_phone': emergencyContactPhone,
          })
          .eq('id', uid);

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
final parentProfileProvider =
    StateNotifierProvider<ParentProfileController, ParentProfileState>(
      (ref) => ParentProfileController(),
    );

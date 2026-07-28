import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/parent_approval_model.dart';

class ParentApprovalState {
  final bool isLoading;
  final List<ParentApprovalModel> parents;
  final String? error;

  const ParentApprovalState({
    this.isLoading = false,
    this.parents = const [],
    this.error,
  });

  ParentApprovalState copyWith({
    bool? isLoading,
    List<ParentApprovalModel>? parents,
    String? error,
  }) {
    return ParentApprovalState(
      isLoading: isLoading ?? this.isLoading,
      parents: parents ?? this.parents,
      error: error,
    );
  }
}

class ParentApprovalController extends StateNotifier<ParentApprovalState> {
  ParentApprovalController() : super(const ParentApprovalState()) {
    loadPendingParents();
  }

  final _client = Supabase.instance.client;

  Future<void> loadPendingParents() async {
    try {
      state = state.copyWith(isLoading: true);

      final data = await _client
          .from('parents')
          .select()
          .eq('approval_status', 'pending')
          .order('created_at', ascending: false);

      state = state.copyWith(
        isLoading: false,
        parents: (data as List)
            .map((e) => ParentApprovalModel.fromJson(e))
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> approveParent(String id) async {
    try {
      await _client
          .from('parents')
          .update({
            'approval_status': 'approved',
            'approved_at': DateTime.now().toIso8601String(),
            'approved_by': _client.auth.currentUser?.id,
            'is_active': true,
          })
          .eq('id', id);

      await loadPendingParents();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectParent(String id) async {
    try {
      await _client
          .from('parents')
          .update({
            'approval_status': 'rejected',
            'approved_at': DateTime.now().toIso8601String(),
            'approved_by': _client.auth.currentUser?.id,
            'is_active': false,
          })
          .eq('id', id);

      await loadPendingParents();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final parentApprovalProvider =
    StateNotifierProvider<ParentApprovalController, ParentApprovalState>(
      (ref) => ParentApprovalController(),
    );

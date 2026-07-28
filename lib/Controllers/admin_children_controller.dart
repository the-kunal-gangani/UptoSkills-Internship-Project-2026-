import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class AdminChildrenState {
  final bool isLoading;
  final List<dynamic> allChildren;
  final List<dynamic> filteredChildren;
  final String searchQuery;
  final String? errorMessage;

  const AdminChildrenState({
    this.isLoading = true,
    this.allChildren = const [],
    this.filteredChildren = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  AdminChildrenState copyWith({
    bool? isLoading,
    List<dynamic>? allChildren,
    List<dynamic>? filteredChildren,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminChildrenState(
      isLoading: isLoading ?? this.isLoading,
      allChildren: allChildren ?? this.allChildren,
      filteredChildren: filteredChildren ?? this.filteredChildren,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class AdminChildrenController
    extends StateNotifier<AdminChildrenState> {
  AdminChildrenController() : super(const AdminChildrenState()) {
    loadChildren();
  }

  final _client = Supabase.instance.client;

  Future<void> loadChildren() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _client
          .from('children')
          .select(
              'id, full_name, date_of_birth, gender, status, '
              'classroom_id, teacher_id, '
              'classrooms(name, code), parents(full_name)')
          .order('full_name');

      data.sort((a, b) {
        final nameA = (a['full_name'] as String? ?? '').toLowerCase();
        final nameB = (b['full_name'] as String? ?? '').toLowerCase();
        return nameA.compareTo(nameB);
      });

      state = state.copyWith(
        isLoading: false,
        allChildren: data,
        filteredChildren: data,
        searchQuery: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void search(String query) {
    final q = query.toLowerCase();
    state = state.copyWith(
      searchQuery: query,
      filteredChildren: q.isEmpty
          ? state.allChildren
          : state.allChildren.where((c) {
              final name =
                  (c['full_name'] as String? ?? '').toLowerCase();
              return name.contains(q);
            }).toList(),
    );
  }

  void clearSearch() => search('');
}

// ── Provider ──────────────────────────────────────────────────────────────────
final adminChildrenProvider =
    StateNotifierProvider<AdminChildrenController, AdminChildrenState>(
  (ref) => AdminChildrenController(),
);
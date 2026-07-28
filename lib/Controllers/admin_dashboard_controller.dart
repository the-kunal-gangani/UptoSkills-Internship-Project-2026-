import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class AdminDashboardState {
  final bool isLoading;
  final Map<String, int> stats;
  final String? errorMessage;
  final DateTime now;

  const AdminDashboardState({
    this.isLoading = false,
    this.stats = const {
      'teachers': 0,
      'pendingTeachers': 0,
      'parents': 0,
      'children': 0,
      'classrooms': 0,
      'unassigned': 0,
    },
    this.errorMessage,
    required this.now,
  });

  AdminDashboardState copyWith({
    bool? isLoading,
    Map<String, int>? stats,
    String? errorMessage,
    bool clearError = false,
    DateTime? now,
  }) {
    return AdminDashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      now: now ?? this.now,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class AdminDashboardController extends StateNotifier<AdminDashboardState> {
  AdminDashboardController() : super(AdminDashboardState(now: DateTime.now())) {
    loadStats();
    _startClock();
  }

  final _client = Supabase.instance.client;
  Timer? _clockTimer;

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      state = state.copyWith(now: DateTime.now());
    });
  }

  String get greeting {
    final hour = state.now.hour;
    if (hour >= 5 && hour < 12) return 'Good morning 🌅';
    if (hour >= 12 && hour < 15) return 'Good afternoon ☀️';
    if (hour >= 15 && hour < 18) return 'Good evening 🌇';
    return 'Good night 🌙';
  }

  String get adminName =>
      _client.auth.currentUser?.userMetadata?['full_name'] as String? ??
      'Admin';

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _client.rpc('admin_dashboard_stats');
      final data = result as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        stats: {
          'teachers': (data['teachers'] as num?)?.toInt() ?? 0,
          'pendingTeachers': (data['pendingTeachers'] as num?)?.toInt() ?? 0,
          'parents': (data['parents'] as num?)?.toInt() ?? 0,
          'children': (data['children'] as num?)?.toInt() ?? 0,
          'classrooms': (data['classrooms'] as num?)?.toInt() ?? 0,
          'unassigned': (data['unassigned'] as num?)?.toInt() ?? 0,
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final adminDashboardProvider =
    StateNotifierProvider<AdminDashboardController, AdminDashboardState>(
      (ref) => AdminDashboardController(),
    );

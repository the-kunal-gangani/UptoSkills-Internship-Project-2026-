import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────
class AdminSessionsState {
  final List<Map<String, dynamic>> pending;
  final List<Map<String, dynamic>> upcoming;
  final List<Map<String, dynamic>> all;
  final List<Map<String, dynamic>> availableStaff;

  // Task 8: session_bookings (new booking system)
  final List<Map<String, dynamic>> pendingBookings;
  final List<Map<String, dynamic>> allBookings;

  final bool isLoading;
  final String? error;

  const AdminSessionsState({
    this.pending = const [],
    this.upcoming = const [],
    this.all = const [],
    this.availableStaff = const [],
    this.pendingBookings = const [],
    this.allBookings = const [],
    this.isLoading = false,
    this.error,
  });

  AdminSessionsState copyWith({
    List<Map<String, dynamic>>? pending,
    List<Map<String, dynamic>>? upcoming,
    List<Map<String, dynamic>>? all,
    List<Map<String, dynamic>>? availableStaff,
    List<Map<String, dynamic>>? pendingBookings,
    List<Map<String, dynamic>>? allBookings,
    bool? isLoading,
    String? error,
  }) =>
      AdminSessionsState(
        pending: pending ?? this.pending,
        upcoming: upcoming ?? this.upcoming,
        all: all ?? this.all,
        availableStaff: availableStaff ?? this.availableStaff,
        pendingBookings: pendingBookings ?? this.pendingBookings,
        allBookings: allBookings ?? this.allBookings,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  int get pendingCount => pending.length;

  /// Total new-system pending bookings that need admin attention.
  int get newBookingsPendingCount => pendingBookings.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────
class AdminSessionsController extends StateNotifier<AdminSessionsState> {
  AdminSessionsController() : super(const AdminSessionsState()) {
    loadAll();
  }

  final _db = Supabase.instance.client;

  // ── Old sessions table select ─────────────────────────────────────────────
  static const _select = '''
    *,
    parents(id, full_name, email, phone),
    teachers(id, full_name, designation),
    session_children(child_id, children(id, full_name))
  ''';

  // ── New session_bookings table select ─────────────────────────────────────
  static const _bookingSelect = '''
    *,
    parents(id, full_name, email, phone),
    teachers(id, full_name, designation),
    children(id, full_name)
  ''';

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final in7Days = DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String()
          .split('T')
          .first;

      final results = await Future.wait([
        // ── Old sessions table ──────────────────────────────────────────────
        // Pending (any date)
        _db
            .from('sessions')
            .select(_select)
            .eq('status', 'pending')
            .order('scheduled_date'),
        // Upcoming: confirmed sessions in next 7 days
        _db
            .from('sessions')
            .select(_select)
            .eq('status', 'confirmed')
            .gte('scheduled_date', today)
            .lte('scheduled_date', in7Days)
            .order('scheduled_date'),
        // All sessions, newest first
        _db
            .from('sessions')
            .select(_select)
            .order('scheduled_date', ascending: false),
        // Active + approved staff
        _db
            .from('teachers')
            .select('id, full_name, designation, staff_id')
            .eq('is_approved', true)
            .eq('is_active', true),

        // ── New session_bookings table ──────────────────────────────────────
        // Pending bookings (new system)
        _db
            .from('session_bookings')
            .select(_bookingSelect)
            .eq('status', 'pending')
            .order('session_date')
            .order('start_time'),
        // All bookings (new system)
        _db
            .from('session_bookings')
            .select(_bookingSelect)
            .order('session_date', ascending: false)
            .order('start_time', ascending: false),
      ]);

      state = state.copyWith(
        pending: List<Map<String, dynamic>>.from(results[0] as List),
        upcoming: List<Map<String, dynamic>>.from(results[1] as List),
        all: List<Map<String, dynamic>>.from(results[2] as List),
        availableStaff: List<Map<String, dynamic>>.from(results[3] as List),
        pendingBookings: List<Map<String, dynamic>>.from(results[4] as List),
        allBookings: List<Map<String, dynamic>>.from(results[5] as List),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Old sessions table actions ────────────────────────────────────────────

  /// Assigns a staff member and confirms the (old) session.
  Future<bool> assignStaff(String sessionId, String staffId) async {
    try {
      await _db.from('sessions').update({
        'staff_id': staffId,
        'status': 'confirmed',
      }).eq('id', sessionId);
      await loadAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelSession(String sessionId) async {
    try {
      await _db
          .from('sessions')
          .update({'status': 'cancelled'})
          .eq('id', sessionId);
      await loadAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── New session_bookings table actions ────────────────────────────────────

  /// Confirms a booking from session_bookings table.
  Future<bool> confirmBooking(String bookingId) async {
    try {
      await _db
          .from('session_bookings')
          .update({'status': 'confirmed'})
          .eq('id', bookingId);
      await loadAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Rejects (cancels) a booking from session_bookings table.
  Future<bool> rejectBooking(String bookingId) async {
    try {
      await _db
          .from('session_bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
      await loadAll();
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────
final adminSessionsProvider =
    StateNotifierProvider<AdminSessionsController, AdminSessionsState>(
  (_) => AdminSessionsController(),
);

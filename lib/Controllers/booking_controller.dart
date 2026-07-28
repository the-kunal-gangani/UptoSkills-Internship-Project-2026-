import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class BookingState {
  final List<Map<String, dynamic>> sessions;
  final List<Map<String, dynamic>> myChildren;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const BookingState({
    this.sessions = const [],
    this.myChildren = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  BookingState copyWith({
    List<Map<String, dynamic>>? sessions,
    List<Map<String, dynamic>>? myChildren,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) =>
      BookingState(
        sessions: sessions ?? this.sessions,
        myChildren: myChildren ?? this.myChildren,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: error,
      );
}

// ── Controller ────────────────────────────────────────────────────────────────
class BookingController extends StateNotifier<BookingState> {
  BookingController() : super(const BookingState()) {
    _init();
  }

  final _db = Supabase.instance.client;

  String? get _uid => _db.auth.currentUser?.id;

  Future<void> _init() async {
    await Future.wait([loadSessions(), loadMyChildren()]);
  }

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _db
          .from('sessions')
          .select('''
            *,
            teachers(id, full_name, designation),
            session_children(child_id, children(id, full_name, avatar_url))
          ''')
          .eq('parent_id', _uid!)
          .order('scheduled_date', ascending: false);
      state = state.copyWith(
        sessions: List<Map<String, dynamic>>.from(data),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMyChildren() async {
    try {
      final data = await _db
          .from('children')
          .select('id, full_name, avatar_url, date_of_birth')
          .eq('parent_id', _uid!);
      state = state.copyWith(
        myChildren: List<Map<String, dynamic>>.from(data),
      );
    } catch (_) {}
  }

  /// Creates a new pending booking.
  /// Returns true on success.
  Future<bool> createBooking({
    required List<String> childIds,
    required DateTime date,
    required String startTime, // 'HH:MM'
    required String endTime,
    required String locationType, // 'home' | 'staff_home'
    String? notes,
  }) async {
    if (childIds.isEmpty || childIds.length > 4) return false;

    state = state.copyWith(isSaving: true);
    try {
      final session = await _db.from('sessions').insert({
        'parent_id': _uid,
        'scheduled_date': date.toIso8601String().split('T').first,
        'scheduled_start': startTime,
        'scheduled_end': endTime,
        'location_type': locationType,
        'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
      }).select('id').single();

      final sessionId = session['id'] as String;

      await _db.from('session_children').insert(
        childIds.map((cid) => {'session_id': sessionId, 'child_id': cid}).toList(),
      );

      await loadSessions();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cancelSession(String sessionId) async {
    try {
      await _db
          .from('sessions')
          .update({'status': 'cancelled'})
          .eq('id', sessionId)
          .eq('parent_id', _uid!);
      await loadSessions();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final bookingProvider =
    StateNotifierProvider<BookingController, BookingState>(
  (_) => BookingController(),
);

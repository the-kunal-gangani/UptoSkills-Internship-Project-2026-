import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/Models/teacher_availability_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────
class TeacherAvailabilityState {
  final List<TeacherAvailabilityModel> slots;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const TeacherAvailabilityState({
    this.slots = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  TeacherAvailabilityState copyWith({
    List<TeacherAvailabilityModel>? slots,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) =>
      TeacherAvailabilityState(
        slots: slots ?? this.slots,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
      );

  /// Returns availability slots for a specific day of week (0=Mon … 6=Sun).
  List<TeacherAvailabilityModel> slotsForDay(int dayOfWeek) =>
      slots.where((s) => s.dayOfWeek == dayOfWeek).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────
class TeacherAvailabilityController
    extends StateNotifier<TeacherAvailabilityState> {
  TeacherAvailabilityController() : super(const TeacherAvailabilityState()) {
    loadAvailability();
  }

  final _db = Supabase.instance.client;
  String? get _uid => _db.auth.currentUser?.id;

  /// Loads all availability slots for the current teacher.
  Future<void> loadAvailability() async {
    if (_uid == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _db
          .from('teacher_availability')
          .select()
          .eq('teacher_id', _uid!)
          .order('day_of_week')
          .order('start_time');

      final slots = (data as List)
          .map((e) => TeacherAvailabilityModel.fromMap(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(slots: slots, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Upserts a single availability slot.
  /// Returns the saved model on success, null on failure.
  Future<TeacherAvailabilityModel?> saveSlot({
    String? existingId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String status,
    required int maxSessionsPerDay,
  }) async {
    if (_uid == null) return null;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final payload = {
        'teacher_id': _uid!,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'status': status,
        'max_sessions_per_day': maxSessionsPerDay,
      };

      Map<String, dynamic> result;
      if (existingId != null) {
        result = await _db
            .from('teacher_availability')
            .update(payload)
            .eq('id', existingId)
            .select()
            .single();
      } else {
        result = await _db
            .from('teacher_availability')
            .insert(payload)
            .select()
            .single();
      }

      await loadAvailability();
      state = state.copyWith(isSaving: false);
      return TeacherAvailabilityModel.fromMap(result);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }

  /// Deletes a specific availability slot.
  Future<bool> deleteSlot(String slotId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _db
          .from('teacher_availability')
          .delete()
          .eq('id', slotId)
          .eq('teacher_id', _uid!);

      await loadAvailability();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Saves a full weekly schedule by replacing all slots for the given days.
  /// [slots] is a list of maps with keys: dayOfWeek, startTime, endTime, status, maxSessionsPerDay.
  Future<bool> saveWeeklySchedule(
    List<Map<String, dynamic>> slots,
  ) async {
    if (_uid == null) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      // Delete all existing slots for this teacher
      await _db
          .from('teacher_availability')
          .delete()
          .eq('teacher_id', _uid!);

      if (slots.isNotEmpty) {
        final inserts = slots
            .map((s) => {
                  'teacher_id': _uid!,
                  'day_of_week': s['dayOfWeek'] as int,
                  'start_time': s['startTime'] as String,
                  'end_time': s['endTime'] as String,
                  'status': s['status'] as String,
                  'max_sessions_per_day': s['maxSessionsPerDay'] as int,
                })
            .toList();
        await _db.from('teacher_availability').insert(inserts);
      }

      await loadAvailability();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────
final teacherAvailabilityProvider = StateNotifierProvider<
    TeacherAvailabilityController, TeacherAvailabilityState>(
  (_) => TeacherAvailabilityController(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Public-facing provider: fetch availability for a specific teacher by ID
// Used by parents when browsing available teachers for booking.
// ─────────────────────────────────────────────────────────────────────────────
final teacherAvailabilityByIdProvider =
    FutureProvider.family<List<TeacherAvailabilityModel>, String>(
  (ref, teacherId) async {
    final db = Supabase.instance.client;
    final data = await db
        .from('teacher_availability')
        .select()
        .eq('teacher_id', teacherId)
        .eq('status', 'available')
        .order('day_of_week')
        .order('start_time');

    return (data as List)
        .map((e) => TeacherAvailabilityModel.fromMap(e as Map<String, dynamic>))
        .toList();
  },
);

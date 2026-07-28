import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/Models/session_booking_model.dart';
import 'package:tinysteps/Models/teacher_availability_model.dart';
import 'package:tinysteps/core/services/notification_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Validation Result
// ─────────────────────────────────────────────────────────────────────────────
class BookingValidationResult {
  final bool isValid;
  final String? errorMessage;

  const BookingValidationResult({required this.isValid, this.errorMessage});

  factory BookingValidationResult.valid() =>
      const BookingValidationResult(isValid: true);

  factory BookingValidationResult.invalid(String message) =>
      BookingValidationResult(isValid: false, errorMessage: message);
}

// ─────────────────────────────────────────────────────────────────────────────
// Available Teacher model used in booking UI
// ─────────────────────────────────────────────────────────────────────────────
class AvailableTeacher {
  final String id;
  final String fullName;
  final String designation;
  final int sessionsToday;
  final int maxSessionsPerDay;
  final List<TeacherAvailabilityModel> availableSlots;

  const AvailableTeacher({
    required this.id,
    required this.fullName,
    required this.designation,
    required this.sessionsToday,
    required this.maxSessionsPerDay,
    required this.availableSlots,
  });

  /// Whether this teacher can accept more sessions today.
  bool get hasCapacity => sessionsToday < maxSessionsPerDay;

  /// Workload score — lower = lighter workload (preferred for load balancing).
  double get workloadScore => maxSessionsPerDay > 0
      ? sessionsToday / maxSessionsPerDay
      : 1.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────
class BookingSessionState {
  final List<SessionBookingModel> myBookings;
  final List<AvailableTeacher> availableTeachers;
  final List<Map<String, dynamic>> myChildren;
  final bool isLoading;
  final bool isLoadingTeachers;
  final bool isSaving;
  final String? error;
  final SessionBookingModel? lastConfirmedBooking;

  const BookingSessionState({
    this.myBookings = const [],
    this.availableTeachers = const [],
    this.myChildren = const [],
    this.isLoading = false,
    this.isLoadingTeachers = false,
    this.isSaving = false,
    this.error,
    this.lastConfirmedBooking,
  });

  BookingSessionState copyWith({
    List<SessionBookingModel>? myBookings,
    List<AvailableTeacher>? availableTeachers,
    List<Map<String, dynamic>>? myChildren,
    bool? isLoading,
    bool? isLoadingTeachers,
    bool? isSaving,
    String? error,
    bool clearError = false,
    SessionBookingModel? lastConfirmedBooking,
  }) =>
      BookingSessionState(
        myBookings: myBookings ?? this.myBookings,
        availableTeachers: availableTeachers ?? this.availableTeachers,
        myChildren: myChildren ?? this.myChildren,
        isLoading: isLoading ?? this.isLoading,
        isLoadingTeachers: isLoadingTeachers ?? this.isLoadingTeachers,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
        lastConfirmedBooking: lastConfirmedBooking ?? this.lastConfirmedBooking,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────
class BookingSessionController extends StateNotifier<BookingSessionState> {
  BookingSessionController() : super(const BookingSessionState()) {
    _init();
  }

  final _db = Supabase.instance.client;
  String? get _uid => _db.auth.currentUser?.id;

  Future<void> _init() async {
    await Future.wait([loadMyBookings(), loadMyChildren()]);
  }

  // ── Load parent's own bookings ────────────────────────────────────────────
  Future<void> loadMyBookings() async {
    if (_uid == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _db
          .from('session_bookings')
          .select('''
            *,
            teachers(id, full_name, designation),
            children(id, full_name)
          ''')
          .eq('parent_id', _uid!)
          .order('session_date', ascending: false)
          .order('start_time', ascending: false);

      final bookings = (data as List)
          .map((e) =>
              SessionBookingModel.fromMap(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(myBookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Load parent's children ────────────────────────────────────────────────
  Future<void> loadMyChildren() async {
    if (_uid == null) return;
    try {
      final data = await _db
          .from('children')
          .select('id, full_name, avatar_url, date_of_birth')
          .eq('parent_id', _uid!);

      state = state.copyWith(
        myChildren: List<Map<String, dynamic>>.from(data as List),
      );
    } catch (_) {}
  }

  // ── Load available teachers for a given date ──────────────────────────────
  Future<void> loadAvailableTeachers(DateTime date) async {
    state = state.copyWith(isLoadingTeachers: true, clearError: true);
    try {
      // dayOfWeek: DateTime weekday is 1(Mon)–7(Sun), our DB is 0(Mon)–6(Sun)
      final dayOfWeek = date.weekday - 1;
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // 1. Get all teachers with availability on this day of week
      final availData = await _db
          .from('teacher_availability')
          .select('''
            *,
            teachers(id, full_name, designation)
          ''')
          .eq('day_of_week', dayOfWeek)
          .eq('status', 'available');

      if ((availData as List).isEmpty) {
        state = state.copyWith(
          availableTeachers: [],
          isLoadingTeachers: false,
        );
        return;
      }

      // 2. Get teacher IDs with leave on this date
      final leaveData = await _db
          .from('teacher_leave')
          .select('teacher_id')
          .eq('leave_date', dateStr);

      final teachersOnLeave = (leaveData as List)
          .map((e) => e['teacher_id'] as String)
          .toSet();

      // 3. Get booking counts for teachers on this date
      final bookingCountData = await _db
          .from('session_bookings')
          .select('teacher_id')
          .eq('session_date', dateStr)
          .neq('status', 'cancelled');

      final bookingCounts = <String, int>{};
      for (final b in (bookingCountData as List)) {
        final tid = b['teacher_id'] as String;
        bookingCounts[tid] = (bookingCounts[tid] ?? 0) + 1;
      }

      // 4. Group availability slots by teacher
      final teacherMap = <String, List<TeacherAvailabilityModel>>{};
      final teacherInfo = <String, Map<String, dynamic>>{};

      for (final item in availData) {
        final map = Map<String, dynamic>.from(item as Map);
        final teacherData = map['teachers'] as Map<String, dynamic>?;
        if (teacherData == null) continue;

        final tid = teacherData['id'] as String;

        // Skip teachers on leave
        if (teachersOnLeave.contains(tid)) continue;

        teacherMap.putIfAbsent(tid, () => []);
        teacherInfo.putIfAbsent(tid, () => teacherData);

        // Build availability model without joined teacher key
        final slotMap = Map<String, dynamic>.from(map)
          ..remove('teachers');
        teacherMap[tid]!
            .add(TeacherAvailabilityModel.fromMap(slotMap));
      }

      // 5. Build AvailableTeacher list, filter by capacity, sort by workload
      final teachers = teacherMap.entries.map((entry) {
        final tid = entry.key;
        final slots = entry.value;
        final info = teacherInfo[tid]!;
        final maxSessions = slots.isNotEmpty
            ? slots.first.maxSessionsPerDay
            : 6;
        final sessionCount = bookingCounts[tid] ?? 0;

        return AvailableTeacher(
          id: tid,
          fullName: info['full_name'] as String? ?? 'Teacher',
          designation: info['designation'] as String? ?? 'Caregiver',
          sessionsToday: sessionCount,
          maxSessionsPerDay: maxSessions,
          availableSlots: slots,
        );
      }).where((t) => t.hasCapacity).toList();

      // Sort by workload (lightest first = load balancing)
      teachers.sort((a, b) => a.workloadScore.compareTo(b.workloadScore));

      state = state.copyWith(
        availableTeachers: teachers,
        isLoadingTeachers: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingTeachers: false, error: e.toString());
    }
  }

  // ── Validate booking before creating ─────────────────────────────────────
  Future<BookingValidationResult> validateBooking({
    required String teacherId,
    required String childId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // 1. Check if teacher is on leave
      final leaveCheck = await _db
          .from('teacher_leave')
          .select('id')
          .eq('teacher_id', teacherId)
          .eq('leave_date', dateStr)
          .maybeSingle();

      if (leaveCheck != null) {
        return BookingValidationResult.invalid(
          'This teacher is on leave on the selected date.',
        );
      }

      // 2. Check daily session limit
      final dayOfWeek = date.weekday - 1;
      final availData = await _db
          .from('teacher_availability')
          .select('max_sessions_per_day')
          .eq('teacher_id', teacherId)
          .eq('day_of_week', dayOfWeek)
          .eq('status', 'available')
          .maybeSingle();

      final maxSessions =
          (availData?['max_sessions_per_day'] as num?)?.toInt() ?? 6;

      final bookingCount = await _db
          .from('session_bookings')
          .select('id')
          .eq('teacher_id', teacherId)
          .eq('session_date', dateStr)
          .neq('status', 'cancelled');

      if ((bookingCount as List).length >= maxSessions) {
        return BookingValidationResult.invalid(
          'This teacher has reached their maximum sessions for the day.',
        );
      }

      // 3. Check for teacher double-booking (overlapping times)
      final conflictsTeacher = await _db
          .from('session_bookings')
          .select('id')
          .eq('teacher_id', teacherId)
          .eq('session_date', dateStr)
          .neq('status', 'cancelled')
          .lte('start_time', endTime)
          .gte('end_time', startTime);

      if ((conflictsTeacher as List).isNotEmpty) {
        return BookingValidationResult.invalid(
          'This teacher already has a booking during the selected time.',
        );
      }

      // 4. Check for parent double-booking
      if (_uid != null) {
        final parentConflicts = await _db
            .from('session_bookings')
            .select('id')
            .eq('parent_id', _uid!)
            .eq('session_date', dateStr)
            .neq('status', 'cancelled')
            .lte('start_time', endTime)
            .gte('end_time', startTime);

        if ((parentConflicts as List).isNotEmpty) {
          return BookingValidationResult.invalid(
            'You already have a booking during the selected time.',
          );
        }
      }

      return BookingValidationResult.valid();
    } catch (e) {
      return BookingValidationResult.invalid('Validation failed: $e');
    }
  }

  // ── Create a new booking ──────────────────────────────────────────────────
  Future<SessionBookingModel?> createBooking({
    required String teacherId,
    required String childId,
    required DateTime date,
    required String startTime, // 'HH:MM'
    required String endTime,
    String? notes,
  }) async {
    if (_uid == null) return null;

    // Validate first
    final validation = await validateBooking(
      teacherId: teacherId,
      childId: childId,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );

    if (!validation.isValid) {
      state = state.copyWith(error: validation.errorMessage);
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final result = await _db
          .from('session_bookings')
          .insert({
            'parent_id': _uid!,
            'child_id': childId,
            'teacher_id': teacherId,
            'session_date': dateStr,
            'start_time': startTime,
            'end_time': endTime,
            'status': 'pending',
            if (notes != null && notes.trim().isNotEmpty)
              'notes': notes.trim(),
          })
          .select('''
            *,
            teachers(id, full_name, designation),
            children(id, full_name)
          ''')
          .single();

      final booking = SessionBookingModel.fromMap(result);

      // ── Notify teacher about new booking ─────────────────────────────────
      _notifyTeacher(
        teacherId: teacherId,
        booking: booking,
      );

      await loadMyBookings();
      state = state.copyWith(
        isSaving: false,
        lastConfirmedBooking: booking,
      );
      return booking;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }

  // ── Cancel a booking ──────────────────────────────────────────────────────
  Future<bool> cancelBooking(String bookingId) async {
    if (_uid == null) return false;
    try {
      await _db
          .from('session_bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId)
          .eq('parent_id', _uid!);

      await loadMyBookings();
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  // ── Send push notification to teacher ────────────────────────────────────
  /// Fire-and-forget: fetch teacher's onesignal_id then send notification.
  /// Errors are swallowed — notification failure must not block booking.
  Future<void> _notifyTeacher({
    required String teacherId,
    required SessionBookingModel booking,
  }) async {
    try {
      final teacherRow = await _db
          .from('teachers')
          .select('onesignal_id, full_name')
          .eq('id', teacherId)
          .maybeSingle();

      final onesignalId =
          teacherRow?['onesignal_id'] as String?;
      if (onesignalId == null || onesignalId.isEmpty) return;

      final childName = booking.childName ?? 'a child';
      final dateStr = booking.formattedDate;
      final timeStr = booking.formattedStartTime;

      await NotificationService.instance.sendToUser(
        onesignalId: onesignalId,
        title: '📅 New Session Booking',
        body: 'You have a new booking for $childName on $dateStr at $timeStr.',
      );
    } catch (e) {
      // Non-critical — log and continue
      // ignore: avoid_print
      print('[BookingSession] Notification failed: $e');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────
final bookingSessionProvider =
    StateNotifierProvider<BookingSessionController, BookingSessionState>(
  (_) => BookingSessionController(),
);

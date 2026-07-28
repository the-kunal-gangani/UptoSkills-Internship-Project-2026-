import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/Models/attendance_model.dart';

import 'attendance_state.dart';

class AttendanceController extends StateNotifier<AttendanceState> {
  AttendanceController(this._supabase) : super(const AttendanceState());

  final SupabaseClient _supabase;

  String get today {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadData() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final teacherId = _supabase.auth.currentUser!.id;

      // Fetch children assigned to this teacher
      final children = await _supabase
          .from('children')
          .select('id, full_name')
          .eq('teacher_id', teacherId)
          .order('full_name');

      // Build attendance map
      final childIds = (children as List)
          .map((c) => c['id'] as String)
          .toList();

      final attendanceMap = <String, AttendanceModel?>{};
      for (final id in childIds) {
        attendanceMap[id] = null;
      }

      // Fetch today's attendance records
      if (childIds.isNotEmpty) {
        final records = await _supabase
            .from('attendance')
            .select('id, child_id, checked_in_at, checked_out_at')
            .eq('date', today)
            .inFilter('child_id', childIds);

        for (final row in (records as List)) {
          attendanceMap[row['child_id'] as String] = AttendanceModel.fromJson(
            row,
          );
        }
      }

      state = state.copyWith(
        loading: false,
        children: List<Map<String, dynamic>>.from(children),
        attendance: attendanceMap,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> _sendAttendanceNotification({
    required String childId,
    required String eventType,
  }) async {
    try {
      final child = await _supabase
          .from('children')
          .select('full_name,parent_id')
          .eq('id', childId)
          .single();

      final parentId = child['parent_id'];

      if (parentId == null) return;

      final childName = child['full_name'] ?? 'Child';

      await _supabase.functions.invoke(
        'send-push-notification',
        body: {
          'user_ids': [parentId],
          'title': eventType == 'checkin'
              ? 'Child Checked In'
              : 'Child Checked Out',
          'body': eventType == 'checkin'
              ? '$childName has been checked in.'
              : '$childName has been checked out.',
          'data': {'type': eventType, 'child_id': childId},
        },
      );
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  Future<void> checkIn(String childId) async {
    state = state.copyWith(saving: {...state.saving, childId: true});

    try {
      final teacherId = _supabase.auth.currentUser!.id;
      final nowUtc = DateTime.now().toUtc().toIso8601String();

      final record = await _supabase
          .from('attendance')
          .upsert({
            'child_id': childId,
            'date': today,
            'checked_in_at': nowUtc,
            'checked_in_by': teacherId,
            'method': 'manual',
          }, onConflict: 'child_id,date')
          .select()
          .single();

      state = state.copyWith(
        attendance: {
          ...state.attendance,
          childId: AttendanceModel.fromJson(record),
        },
        saving: {...state.saving, childId: false},
      );
      await _sendAttendanceNotification(childId: childId, eventType: 'checkin');
    } catch (_) {
      state = state.copyWith(saving: {...state.saving, childId: false});
    }
  }

  Future<void> checkOut(String childId) async {
    final existing = state.attendance[childId];
    if (existing == null) return;

    state = state.copyWith(saving: {...state.saving, childId: true});

    try {
      final teacherId = _supabase.auth.currentUser!.id;
      final nowUtc = DateTime.now().toUtc().toIso8601String();

      await _supabase
          .from('attendance')
          .update({'checked_out_at': nowUtc, 'checked_out_by': teacherId})
          .eq('id', existing.id);

      final updated = existing.copyWith(checkedOutAt: nowUtc);

      state = state.copyWith(
        attendance: {...state.attendance, childId: updated},
        saving: {...state.saving, childId: false},
      );
      await _sendAttendanceNotification(childId: childId, eventType: 'checkin');
    } catch (_) {
      state = state.copyWith(saving: {...state.saving, childId: false});
    }
  }

  Future<void> undo(String childId) async {
    final existing = state.attendance[childId];
    if (existing == null) return;

    state = state.copyWith(saving: {...state.saving, childId: true});

    try {
      await _supabase.from('attendance').delete().eq('id', existing.id);

      state = state.copyWith(
        attendance: {...state.attendance, childId: null},
        saving: {...state.saving, childId: false},
      );
    } catch (_) {
      state = state.copyWith(saving: {...state.saving, childId: false});
    }
  }
}

extension CopyWith on AttendanceModel {
  AttendanceModel copyWith({
    String? id,
    String? childId,
    String? checkedInAt,
    String? checkedOutAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedOutAt: checkedOutAt ?? this.checkedOutAt,
    );
  }
}

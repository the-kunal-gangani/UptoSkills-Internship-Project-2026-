import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/Controllers/attendance_controller.dart';
import 'package:tinysteps/Controllers/attendance_state.dart';

final attendanceProvider =
    StateNotifierProvider<AttendanceController, AttendanceState>((ref) {
      return AttendanceController(Supabase.instance.client);
    });

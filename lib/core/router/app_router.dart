import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth
import 'package:tinysteps/views/auth/screens/login_screen.dart';
import 'package:tinysteps/views/auth/screens/register_screen.dart';
import 'package:tinysteps/views/auth/screens/forgot_pass_screen.dart';
import 'package:tinysteps/views/auth/screens/change_password_screen.dart';
import 'package:tinysteps/views/admin/screens/pending_approval_screen.dart';

// Parent
import 'package:tinysteps/views/parent/screens/parent_home_screen.dart';
import 'package:tinysteps/views/parent/screens/my_children_screen.dart';
import 'package:tinysteps/views/parent/screens/add_child_screen.dart';
import 'package:tinysteps/views/parent/screens/child_profile_screen.dart';
import 'package:tinysteps/views/parent/screens/attendance_history_screen.dart';
import 'package:tinysteps/views/parent/screens/book_session_screen.dart';
import 'package:tinysteps/views/parent/screens/booking_confirmation_screen.dart';
import 'package:tinysteps/views/parent/screens/my_sessions_screen.dart';
import 'package:tinysteps/views/parent/screens/child_insights_screen.dart';
import 'package:tinysteps/Models/session_booking_model.dart';

// Staff
import 'package:tinysteps/views/staff/screens/attendance_screen.dart';
import 'package:tinysteps/views/staff/screens/child_detail_screen.dart';
import 'package:tinysteps/views/staff/screens/my_classroom_screen.dart';
import 'package:tinysteps/views/staff/screens/teacher_faq_screen.dart';
import 'package:tinysteps/views/staff/screens/teacher_home_screen.dart';
import 'package:tinysteps/views/staff/screens/my_schedule_screen.dart';
import 'package:tinysteps/views/staff/screens/growth_form_screen.dart';
import 'package:tinysteps/views/staff/screens/teacher_availability_screen.dart';
import 'package:tinysteps/views/staff/screens/teacher_leave_screen.dart';

// Admin
import 'package:tinysteps/views/admin/screens/admin_home_screen.dart';
import 'package:tinysteps/views/admin/screens/privacy_policy_screen.dart';
import 'package:tinysteps/views/admin/screens/sessions_screen.dart';
import 'package:tinysteps/views/admin/screens/add_staff_screen.dart';

// Core
import 'package:tinysteps/core/screens/notifications_screen.dart';
import 'package:tinysteps/core/screens/support_screen.dart';
import 'package:tinysteps/core/screens/app_settings_screen.dart';
import 'package:tinysteps/core/screens/about_app_screen.dart';
import 'package:tinysteps/core/screens/chat_screen.dart';

class _SupabaseAuthNotifier extends ChangeNotifier {
  _SupabaseAuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authNotifier = _SupabaseAuthNotifier();

String _routeForRole(String? role) => switch (role) {
  'teacher' => '/teacher',
  'admin' => '/admin',
  _ => '/parent',
};

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _authNotifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final loc = state.matchedLocation;
      final isOnAuth =
          loc == '/login' || loc == '/register' || loc == '/forgot-password';
      final isOnPending = loc == '/pending-approval';

      if (!isLoggedIn && !isOnAuth && !isOnPending) return '/login';

      if (isLoggedIn && isOnAuth) {
        if (loc == '/forgot-password') return null;
        final role = session.user.userMetadata?['role'] as String?;
        return _routeForRole(role);
      }

      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (c, s) => const ForgotPassScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (c, s) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (c, s) => const PendingApprovalScreen(),
      ),

      // ── Parent ────────────────────────────────────────────────────────────
      GoRoute(path: '/parent', builder: (c, s) => const ParentHomeScreen()),
      GoRoute(
        path: '/parent/children',
        builder: (c, s) => const MyChildrenScreen(),
      ),
      GoRoute(
        path: '/parent/children/add',
        builder: (c, s) => const AddChildScreen(),
      ),
      GoRoute(
        path: '/parent/children/:childId',
        builder: (c, s) => ChildProfileScreen(
          childId: s.pathParameters['childId']!,
          childName: s.uri.queryParameters['name'] ?? '',
        ),
      ),
      GoRoute(
        path: '/parent/attendance',
        builder: (c, s) => const AttendanceHistoryScreen(),
      ),
      GoRoute(
        path: '/parent/sessions',
        builder: (c, s) => const MySessionsScreen(),
      ),
      GoRoute(
        path: '/parent/book-session',
        builder: (c, s) => const BookSessionScreen(),
      ),
      GoRoute(
        path: '/parent/booking-confirmation',
        builder: (c, s) {
          final booking = s.extra as SessionBookingModel;
          return BookingConfirmationScreen(booking: booking);
        },
      ),

      // ── Staff ─────────────────────────────────────────────────────────────
      GoRoute(path: '/teacher', builder: (c, s) => const TeacherHomeScreen()),
      GoRoute(
        path: '/teacher/attendance',
        builder: (c, s) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/teacher/classroom',
        builder: (c, s) => const MyClassroomScreen(),
      ),
      GoRoute(path: '/faq', builder: (c, s) => const TeacherFAQScreen()),
      GoRoute(
        path: '/teacher/child/:childId',
        builder: (c, s) => ChildDetailScreen(
          childId: s.pathParameters['childId']!,
          childName: s.uri.queryParameters['name'] ?? 'Child',
        ),
      ),
      GoRoute(
        path: '/teacher/child/:childId/growth-form',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          final childName = extra?['childName'] ?? s.uri.queryParameters['name'];
          return GrowthFormScreen(
            childId: s.pathParameters['childId']!,
            childName: childName,
          );
        },
      ),
      GoRoute(
        path: '/teacher/schedule',
        builder: (c, s) => const MyScheduleScreen(),
      ),
      GoRoute(
        path: '/teacher/availability',
        builder: (c, s) => const TeacherAvailabilityScreen(),
      ),
      GoRoute(
        path: '/teacher/leave',
        builder: (c, s) => const TeacherLeaveScreen(),
      ),

      // ── Admin ─────────────────────────────────────────────────────────────
      GoRoute(path: '/admin', builder: (c, s) => const AdminHomeScreen()),
      GoRoute(
        path: '/privacy-policy',
        builder: (c, s) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/admin/sessions',
        builder: (c, s) => const SessionsScreen(),
      ),
      GoRoute(
        path: '/admin/add-staff',
        builder: (c, s) => const AddStaffScreen(),
      ),

      // ── Shared ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/notifications',
        builder: (c, s) => const NotificationsScreen(),
      ),
      GoRoute(path: '/support', builder: (c, s) => const SupportScreen()),
      GoRoute(
        path: '/app-settings',
        builder: (c, s) => const AppSettingsScreen(),
      ),
      GoRoute(path: '/about', builder: (c, s) => const AboutAppScreen()),
      GoRoute(
        path: '/chat/:sessionId',
        builder: (c, s) =>
            ChatScreen(sessionId: s.pathParameters['sessionId']!),
      ),
      GoRoute(
        path: '/child/:childId/insights',
        builder: (c, s) => ChildInsightsScreen(
          childId: s.pathParameters['childId']!,
          childName: s.uri.queryParameters['name'] ?? 'Child',
        ),
      ),
    ],
  );
});

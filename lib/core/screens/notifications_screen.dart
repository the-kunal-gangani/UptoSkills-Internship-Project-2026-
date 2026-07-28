import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

/// Role-aware notifications preferences screen.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabase = Supabase.instance.client;
  String _role = '';

  // Local state for toggles (will be wired to backend later)
  bool _t1 = true;
  bool _t2 = true;
  bool _t3 = false;
  bool _t4 = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  void _loadRole() {
    final meta = _supabase.auth.currentUser?.userMetadata;
    setState(() {
      _role = meta?['role']?.toString().toLowerCase() ?? 'parent';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Notifications', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage your notification preferences to stay updated.',
              style: context.textStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildRoleSpecificToggles(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSpecificToggles() {
    if (_role == 'admin') {
      return _buildCard([
        _toggleTile(
          'System Alerts',
          'Critical system and security alerts',
          _t1,
          (v) => setState(() => _t1 = v),
        ),
        Divider(height: 1, color: context.colors.border),
        _toggleTile(
          'Staff Approvals',
          'Notify when a new caregiver signs up',
          _t2,
          (v) => setState(() => _t2 = v),
        ),
        Divider(height: 1, color: context.colors.border),
        _toggleTile(
          'New Bookings',
          'Alert for new session booking requests',
          _t3,
          (v) => setState(() => _t3 = v),
        ),
      ]);
    } else if (_role == 'teacher') {
      return _buildCard([
        _toggleTile(
          'Session Alerts',
          'New sessions assigned and schedule changes',
          _t1,
          (v) => setState(() => _t1 = v),
        ),
        Divider(height: 1, color: context.colors.border),
        _toggleTile(
          'Admin Announcements',
          'Important messages from administration',
          _t2,
          (v) => setState(() => _t2 = v),
        ),
        Divider(height: 1, color: context.colors.border),
        _toggleTile(
          'Activity Reminders',
          'Reminders to log child activities after a session',
          _t3,
          (v) => setState(() => _t3 = v),
        ),
      ]);
    } else {
      // Parent
      return _buildCard([
        _toggleTile(
          'Check-in / Check-out',
          'Real-time alerts when your child arrives or leaves',
          _t1,
          (v) => setState(() => _t1 = v),
        ),
        Divider(height: 1, color: context.colors.border),
        _toggleTile(
          'Emergency Alerts',
          'Critical daycare closures or emergencies',
          _t2,
          (v) => setState(() => _t2 = v),
        ),
        Divider(height: 1, color: context.colors.border),
        _toggleTile(
          'Payment Reminders',
          'Upcoming fee deadlines and receipts',
          _t3,
          (v) => setState(() => _t3 = v),
        ),
        Divider(height: 1, color: context.colors.border),
        _toggleTile(
          'Announcements',
          'General daycare news and events',
          _t4,
          (v) => setState(() => _t4 = v),
        ),
      ]);
    }
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(children: children),
    );
  }

  Widget _toggleTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      title: Text(title, style: context.textStyles.labelBold),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: context.textStyles.bodySmall),
      ),
      activeThumbColor: context.colors.primary,
      activeTrackColor: context.colors.primaryLight,
      value: value,
      onChanged: onChanged,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:url_launcher/url_launcher.dart';

class ChildDetailScreen extends StatefulWidget {
  final String childId;
  final String childName;

  const ChildDetailScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  final _supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadChildDetails();
  }

  Future<Map<String, dynamic>> _loadChildDetails() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final childRow = await _supabase
        .from('children')
        .select('*')
        .eq('id', widget.childId)
        .maybeSingle();

    final attendanceRow = await _supabase
        .from('attendance')
        .select('checked_in_at, checked_out_at')
        .eq('child_id', widget.childId)
        .eq('date', today)
        .maybeSingle();

    return {'child': childRow ?? {}, 'attendance': attendanceRow};
  }

  String _calcAge(String dob) {
    try {
      final birth = DateTime.parse(dob);
      final now = DateTime.now();
      int years = now.year - birth.year;
      int months = now.month - birth.month;
      if (now.day < birth.day) months--;
      if (months < 0) {
        years--;
        months += 12;
      }
      if (years > 0) return '$years yr${years > 1 ? 's' : ''}';
      return '$months month${months != 1 ? 's' : ''}';
    } catch (_) {
      return 'Unknown age';
    }
  }

  String _formatTime(String? raw) {
    if (raw == null) return '—';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return '—';
    }
  }

  Widget _buildField(String label, String value, {bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textStyles.bodyMuted),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textStyles.bodyLarge.copyWith(
              color: isAlert ? context.colors.danger : context.colors.textDark,
              fontWeight: isAlert ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentCallCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: context.colors.secondaryLight,
            child: Text(
              'P',
              style: context.textStyles.labelBold.copyWith(
                color: context.colors.secondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mother: Priya Sharma',
                  style: context.textStyles.labelBold,
                ),
                const SizedBox(height: 2),
                Text(
                  '+91 98765 43210',
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final Uri url = Uri(scheme: 'tel', path: '+919876543210');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            icon: const Icon(Icons.phone_rounded, size: 16),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.success,
              foregroundColor: context.colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Add Activity'),
                  onTap: () {
                    Navigator.pop(context);

                    context.push(
                      '/teacher/child/${widget.childId}/activity-dashboard',
                      extra: {'childName': widget.childName},
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('See Activity'),
                  onTap: () {
                    Navigator.pop(context);

                    context.push(
                      '/teacher/child/${widget.childId}/activity-history',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text(widget.childName, style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/teacher');
            }
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading details\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: context.textStyles.bodyMuted,
              ),
            );
          }

          final data = snapshot.data;
          final child = data?['child'] as Map<String, dynamic>? ?? {};
          final attendance = data?['attendance'] as Map<String, dynamic>?;

          final name = child['full_name'] as String? ?? widget.childName;
          final dob = child['date_of_birth'] as String?;
          final ageStr = dob != null ? _calcAge(dob) : 'Unknown age';
          final gender = child['gender'] as String? ?? 'N/A';
          final allergies = child['allergies'] as String?;
          final status = child['status'] as String? ?? 'active';

          final checkInStr = attendance != null
              ? _formatTime(attendance['checked_in_at'] as String?)
              : 'Not here';
          final checkOutStr = attendance != null
              ? _formatTime(attendance['checked_out_at'] as String?)
              : '—';

          final isCheckedIn =
              attendance != null &&
              attendance['checked_in_at'] != null &&
              attendance['checked_out_at'] == null;
          final hasAllergies =
              allergies != null &&
              allergies.trim().isNotEmpty &&
              allergies.toLowerCase() != 'none';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: context.colors.primaryLight,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'C',
                          style: context.textStyles.heading1.copyWith(
                            color: context.colors.primary,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(name, style: context.textStyles.heading1),
                      const SizedBox(height: 4),
                      Text(ageStr, style: context.textStyles.bodyMuted),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isCheckedIn
                              ? context.colors.success.withValues(alpha: 0.1)
                              : context.colors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          isCheckedIn
                              ? 'Currently In Class'
                              : (status == 'checked_out'
                                    ? 'Picked Up'
                                    : 'Enrolled'),
                          style: context.textStyles.labelBold.copyWith(
                            color: isCheckedIn
                                ? context.colors.success
                                : context.colors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                Text('Emergency Contact', style: context.textStyles.heading2),
                const SizedBox(height: AppSpacing.md),
                _buildParentCallCard(),
                const SizedBox(height: AppSpacing.xxl),

                Text('Today\'s Attendance', style: context.textStyles.heading2),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.colors.border),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Check In', style: context.textStyles.bodyMuted),
                          const SizedBox(height: 4),
                          Text(
                            checkInStr,
                            style: context.textStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: context.colors.border,
                      ),
                      Column(
                        children: [
                          Text(
                            'Check Out',
                            style: context.textStyles.bodyMuted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            checkOutStr,
                            style: context.textStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Forms Section
                Text('Forms', style: context.textStyles.heading2),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Log nutrition, incidents, activities and more for this child.',
                  style: context.textStyles.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.xl),
                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.local_activity_rounded),
                    label: const Text('Activity'),
                    onPressed: _showActivityOptions,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.restaurant_rounded),
                    label: const Text('Nutrition'),
                    onPressed: () => context.push(
                      '/teacher/child/${widget.childId}/nutrition'
                      '?name=${Uri.encodeComponent(widget.childName)}',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.report_problem_rounded),
                    label: const Text('Incident'),
                    onPressed: () => context.push(
                      '/teacher/child/${widget.childId}/incident'
                      '?name=${Uri.encodeComponent(widget.childName)}',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.show_chart_rounded),
                    label: const Text('Growth'),
                    onPressed: () => context.push(
                      '/teacher/child/${widget.childId}/growth-form'
                      '?name=${Uri.encodeComponent(widget.childName)}',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Details Section
                Text('Child Information', style: context.textStyles.heading2),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.colors.border),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField('Full Name', name),
                      _buildField('Date of Birth', dob ?? 'N/A'),
                      _buildField('Gender', gender),
                      if (hasAllergies)
                        _buildField(
                          'Allergies & Medical Notes',
                          allergies,
                          isAlert: true,
                        ),
                      if (!hasAllergies)
                        _buildField('Allergies', 'None reported'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

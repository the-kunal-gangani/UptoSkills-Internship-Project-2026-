import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

// ── Placeholder data model ────────────────────────────────────────────────────
class AnalyticsData {
  final String titleName;
  final double goalPercentage;
  final String goalMainText;
  final String goalSubText;
  final String milkText;
  final String solidText;
  final String weightText;
  final String weightSub;
  final String heightText;
  final String heightSub;
  final String teacherName;
  final String teacherTime;
  final String teacherNote;

  const AnalyticsData({
    required this.titleName,
    required this.goalPercentage,
    required this.goalMainText,
    required this.goalSubText,
    required this.milkText,
    required this.solidText,
    required this.weightText,
    required this.weightSub,
    required this.heightText,
    required this.heightSub,
    required this.teacherName,
    required this.teacherTime,
    required this.teacherNote,
  });
}

const List<AnalyticsData> _placeholders = [
  AnalyticsData(
    titleName: 'Liam',
    goalPercentage: 0.75,
    goalMainText: '450ml',
    goalSubText: 'OF 600ML GOAL',
    milkText: '75%',
    solidText: '2/3',
    weightText: '11.4 kg',
    weightSub: '+200g from last visit',
    heightText: '84.5 cm',
    heightSub: '85th Percentile',
    teacherName: 'Ms. Sarah',
    teacherTime: 'Today at 2:45 PM',
    teacherNote:
        '"Liam had a great appetite today! He especially loved the mashed sweet potatoes."',
  ),
  AnalyticsData(
    titleName: 'Emma',
    goalPercentage: 0.90,
    goalMainText: '540ml',
    goalSubText: 'OF 600ML GOAL',
    milkText: '90%',
    solidText: '3/3',
    weightText: '10.2 kg',
    weightSub: '+150g from last visit',
    heightText: '79.0 cm',
    heightSub: '75th Percentile',
    teacherName: 'Mr. David',
    teacherTime: 'Today at 1:15 PM',
    teacherNote:
        '"Emma finished all her meals today and was very energetic during playtime!"',
  ),
  AnalyticsData(
    titleName: 'Noah',
    goalPercentage: 0.50,
    goalMainText: '300ml',
    goalSubText: 'OF 600ML GOAL',
    milkText: '50%',
    solidText: '1/3',
    weightText: '12.1 kg',
    weightSub: '+50g from last visit',
    heightText: '86.2 cm',
    heightSub: '90th Percentile',
    teacherName: 'Ms. Chloe',
    teacherTime: 'Today at 3:30 PM',
    teacherNote:
        '"Noah was a bit fussy during lunch but managed to eat his soup."',
  ),
  AnalyticsData(
    titleName: 'Olivia',
    goalPercentage: 0.85,
    goalMainText: '510ml',
    goalSubText: 'OF 600ML GOAL',
    milkText: '85%',
    solidText: '2/3',
    weightText: '9.8 kg',
    weightSub: '+100g from last visit',
    heightText: '78.5 cm',
    heightSub: '70th Percentile',
    teacherName: 'Ms. Sarah',
    teacherTime: 'Today at 12:45 PM',
    teacherNote: '"Olivia did a fantastic job with solid foods today!"',
  ),
  AnalyticsData(
    titleName: 'James',
    goalPercentage: 1.0,
    goalMainText: '600ml',
    goalSubText: 'OF 600ML GOAL',
    milkText: '100%',
    solidText: '3/3',
    weightText: '13.0 kg',
    weightSub: '+300g from last visit',
    heightText: '89.0 cm',
    heightSub: '95th Percentile',
    teacherName: 'Mr. David',
    teacherTime: 'Today at 4:00 PM',
    teacherNote:
        '"James hit all his nutrition goals today and shared snacks with friends!"',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late final AnalyticsData data;

  @override
  void initState() {
    super.initState();
    data = _placeholders[math.Random().nextInt(_placeholders.length)];
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['full_name'] as String? ?? 'Parent';
    final firstName = name.split(' ').first;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: context.colors.primaryLight,
              child: Text(
                initial,
                style: context.textStyles.labelBold.copyWith(
                  color: context.colors.primary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              firstName,
              style: context.textStyles.heading2.copyWith(
                color: context.colors.textDark,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded),
            color: context.colors.textDark,
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text('Growth & Nutrition', style: context.textStyles.heading1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Monitoring ${data.titleName}\'s daily and weekly intake',
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Center(
                child: HalfCircleProgress(
                  percentage: data.goalPercentage,
                  mainText: data.goalMainText,
                  subText: data.goalSubText,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  InfoCard(
                    icon: Icon(
                      Icons.water_drop,
                      color: context.colors.primaryDark,
                      size: 20,
                    ),
                    label: 'MILK\nCONSUMPTION',
                    value: data.milkText,
                    iconBgColor: context.colors.primaryLight.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  InfoCard(
                    icon: Icon(
                      Icons.restaurant,
                      color: context.colors.accent,
                      size: 20,
                    ),
                    label: 'SOLID\nMEALS',
                    value: data.solidText,
                    iconBgColor: context.colors.accentLight.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weekly Intake', style: context.textStyles.heading2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 14,
                          color: context.colors.primaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stable Growth',
                          style: context.textStyles.labelMedium.copyWith(
                            color: context.colors.primaryDark,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Container(
                height: 180,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.md,
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((
                          day,
                        ) {
                          final isSelected = day == 'Wed';
                          return Text(
                            day,
                            style: context.textStyles.bodySmall.copyWith(
                              color: isSelected
                                  ? context.colors.primaryDark
                                  : context.colors.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  MeasurementCard(
                    iconData: Icons.monitor_weight_outlined,
                    label: 'LAST WEIGHT',
                    value: data.weightText,
                    subtext: data.weightSub,
                    bgColor: context.colors.accent.withValues(alpha: 0.15),
                    iconColor: context.colors.accent,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  MeasurementCard(
                    iconData: Icons.straighten,
                    label: 'CURRENT HEIGHT',
                    value: data.heightText,
                    subtext: data.heightSub,
                    bgColor: context.colors.primaryLight.withValues(alpha: 0.3),
                    iconColor: context.colors.primaryDark,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Notes from Caregiver', style: context.textStyles.heading2),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.colors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      context.colors.bgSurface,
                      context.colors.primaryLight.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: context.colors.secondary,
                      child: Text(
                        data.teacherName
                            .replaceAll('Ms. ', '')
                            .replaceAll('Mr. ', '')[0],
                        style: context.textStyles.heading3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                data.teacherName,
                                style: context.textStyles.labelBold,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                data.teacherTime,
                                style: context.textStyles.caption,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            data.teacherNote,
                            style: context.textStyles.bodyMedium.copyWith(
                              fontStyle: FontStyle.italic,
                              color: context.colors.textMedium,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────
class HalfCircleProgress extends StatelessWidget {
  final double percentage;
  final String mainText;
  final String subText;

  const HalfCircleProgress({
    super.key,
    required this.percentage,
    required this.mainText,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: const Size(300, 150),
            painter: _HalfCirclePainter(
              percentage: percentage,
              backgroundColor: context.colors.border.withValues(alpha: 0.5),
              progressColor: context.colors.primaryDark,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mainText,
                style: context.textStyles.heading1.copyWith(
                  fontSize: 40,
                  color: context.colors.textDark,
                ),
              ),
              Text(
                subText,
                style: context.textStyles.labelMedium.copyWith(
                  color: context.colors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _HalfCirclePainter extends CustomPainter {
  final double percentage;
  final Color backgroundColor;
  final Color progressColor;

  _HalfCirclePainter({
    required this.percentage,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 24.0;
    final rect = Rect.fromLTRB(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth / 2,
      size.height * 2 - strokeWidth / 2,
    );

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);
    canvas.drawArc(rect, math.pi, math.pi * percentage, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _HalfCirclePainter old) =>
      old.percentage != percentage;
}

class InfoCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final Color iconBgColor;

  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 18, backgroundColor: iconBgColor, child: icon),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textStyles.caption.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: context.textStyles.heading2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MeasurementCard extends StatelessWidget {
  final IconData iconData;
  final String label;
  final String value;
  final String subtext;
  final Color bgColor;
  final Color iconColor;

  const MeasurementCard({
    super.key,
    required this.iconData,
    required this.label,
    required this.value,
    required this.subtext,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(iconData, size: 16, color: context.colors.bgSurface),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              label,
              style: context.textStyles.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: context.textStyles.heading2),
            const SizedBox(height: 4),
            Text(subtext, style: context.textStyles.caption),
          ],
        ),
      ),
    );
  }
}

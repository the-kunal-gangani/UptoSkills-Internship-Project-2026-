import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tinysteps/Controllers/activity_history_controller.dart';
import 'package:tinysteps/Controllers/parent_children_controller.dart';
import 'package:tinysteps/Models/history_entry_model.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/core/widgets/logout_dialog.dart';

// Declare selected child state provider locally
final selectedChildIdProvider = StateProvider<String?>((ref) => null);

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenState = ref.watch(parentChildrenProvider);
    final selectedChildId = ref.watch(selectedChildIdProvider);

    // If loading children and list is empty, show a centered spinner
    if (childrenState.isLoading && childrenState.children.isEmpty) {
      return Scaffold(
        backgroundColor: context.colors.bgLight,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Determine selected child
    final children = childrenState.children;
    dynamic selectedChild;
    for (final c in children) {
      if (c != null && c['id'] == selectedChildId) {
        selectedChild = c;
        break;
      }
    }
    if (selectedChild == null && children.isNotEmpty) {
      selectedChild = children.first;
    }

    // If no children in DB, fallback to mock child "Liam"
    final String childId = selectedChild != null
        ? selectedChild['id'] as String
        : 'mock-liam';
    final String childName = selectedChild != null
        ? selectedChild['full_name'] as String? ?? 'Child'
        : 'Liam';
    final String childStatus = selectedChild != null
        ? selectedChild['status'] as String? ?? 'active'
        : 'active';

    // Watch history for the child from Supabase
    final historyAsync = childId != 'mock-liam'
        ? ref.watch(activityHistoryProvider(childId))
        : const AsyncValue<List<HistoryEntry>>.data([]);

    return Scaffold(
      backgroundColor: context.isDarkMode
          ? context.colors.bgLight
          : const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: context.isDarkMode
            ? context.colors.bgLight
            : const Color(0xFFFDFBF7),
        elevation: 0,
        titleSpacing: AppSpacing.md,
        title: _buildChildSelector(
          context,
          ref,
          children,
          childName,
          selectedChildId,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            color: context.colors.textDark,
            iconSize: 26,
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            color: context.colors.textDark,
            iconSize: 26,
            tooltip: 'Sign Out',
            onPressed: () async {
              final confirmed = await showLogoutDialog(context);
              if (confirmed) {
                await Supabase.instance.client.auth.signOut();
              }
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Stacked FABs
          Positioned(
            bottom: 72,
            right: 0,
            child: FloatingActionButton(
              heroTag: 'parent_chat_fab',
              onPressed: () => context.push('/support'),
              backgroundColor: const Color(0xFF2E5E65),
              elevation: 4,
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: 'parent_add_fab',
            onPressed: () {
              if (childId != 'mock-liam') {
                _showPlusActions(context, childId, childName);
              } else {
                // If viewing mock child, let them register a new child
                context.push('/parent/children/add');
              }
            },
            backgroundColor: const Color(0xFF006852),
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () async {
          await ref.read(parentChildrenProvider.notifier).loadChildren();
          if (childId != 'mock-liam') {
            ref.invalidate(activityHistoryProvider(childId));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              _buildNappingCard(context, childName, childStatus),
              const SizedBox(height: 32),
              historyAsync.when(
                data: (entries) {
                  return _buildFeedDashboard(
                    context,
                    childName: childName,
                    entries: entries,
                  );
                },
                loading: () => _buildFeedDashboardSkeleton(context),
                error: (err, stack) => _buildFeedDashboard(
                  context,
                  childName: childName,
                  entries: const [],
                ),
              ),
              const SizedBox(
                height: 100,
              ), // Extra spacing for bottom navigation overlap
            ],
          ),
        ),
      ),
    );
  }

  // Header child selector logic
  Widget _buildChildSelector(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> children,
    String selectedName,
    String? selectedId,
  ) {
    if (children.length <= 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(selectedName),
          const SizedBox(width: AppSpacing.sm),
          Text(
            selectedName,
            style: context.textStyles.heading2.copyWith(
              color: const Color(0xFF51BFA8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(selectedName),
          const SizedBox(width: AppSpacing.sm),
          Text(
            selectedName,
            style: context.textStyles.heading2.copyWith(
              color: const Color(0xFF51BFA8),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, color: Color(0xFF51BFA8)),
        ],
      ),
      onSelected: (String childId) {
        ref.read(selectedChildIdProvider.notifier).state = childId;
      },
      itemBuilder: (BuildContext context) {
        return children.map<PopupMenuEntry<String>>((child) {
          final name = child['full_name'] as String? ?? 'Child';
          final id = child['id'] as String;
          final isSelected =
              id == selectedId ||
              (selectedId == null && children.first['id'] == id);
          return PopupMenuItem<String>(
            value: id,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isSelected
                      ? context.colors.primaryLight
                      : context.colors.bgMuted,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'C',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.textMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.textDark,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(Icons.check, color: context.colors.primary, size: 16),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildAvatar(String name) {
    final isLiam = name.toLowerCase() == 'liam';
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDE6),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        isLiam ? '👦' : (name.isNotEmpty ? name[0].toUpperCase() : '👶'),
        style: TextStyle(
          fontSize: isLiam ? 20 : 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Napping Card matching the template
  Widget _buildNappingCard(
    BuildContext context,
    String childName,
    String childStatus,
  ) {
    final isActive =
        childStatus.toLowerCase() == 'active' ||
        childStatus.toLowerCase() == 'checked in';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        gradient: context.isDarkMode
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.colors.primary.withValues(alpha: 0.15),
                  context.colors.bgSurface,
                ],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD4EFFF), Color(0xFFF0F9FF), Colors.white],
                stops: [0.0, 0.6, 1.0],
              ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Secure Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF23605E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  isActive
                      ? 'Secure Status: Active'
                      : 'Secure Status: Inactive',
                  style: context.textStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$childName is currently\nnapping',
            textAlign: TextAlign.center,
            style: context.textStyles.heading1.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: context.colors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Expected wake up in 45 mins',
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: Image.asset(
              'assets/images/napping.jpeg',
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 190,
                color: context.colors.bgMuted,
                alignment: Alignment.center,
                child: Icon(
                  Icons.nightlight_round_rounded,
                  size: 48,
                  color: context.colors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedDashboard(
    BuildContext context, {
    required String childName,
    required List<HistoryEntry> entries,
  }) {
    final activities = entries.isEmpty
        ? _mockDashboardActivities(childName)
        : _activitiesFromHistory(entries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDailySummaryCard(context, childName, activities),
        const SizedBox(height: AppSpacing.lg),
        _buildStatGrid(context, entries, activities.length),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            if (!isWide) {
              return Column(
                children: [
                  _buildTodayActivitiesCard(context, activities),
                  const SizedBox(height: AppSpacing.md),
                  _buildPhotosCard(context),
                  const SizedBox(height: AppSpacing.md),
                  _buildGrowthSnapshotCard(context),
                  const SizedBox(height: AppSpacing.md),
                  _buildIncidentCard(context),
                  const SizedBox(height: AppSpacing.md),
                  _buildAiInsightCard(context, childName),
                  const SizedBox(height: AppSpacing.md),
                  _buildParentSuggestionsCard(context, childName),
                  const SizedBox(height: AppSpacing.md),
                  _buildWeeklyProgressCard(context),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: Column(
                    children: [
                      _buildTodayActivitiesCard(context, activities),
                      const SizedBox(height: AppSpacing.md),
                      _buildWeeklyProgressCard(context),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      _buildPhotosCard(context),
                      const SizedBox(height: AppSpacing.md),
                      _buildGrowthSnapshotCard(context),
                      const SizedBox(height: AppSpacing.md),
                      _buildIncidentCard(context),
                      const SizedBox(height: AppSpacing.md),
                      _buildAiInsightCard(context, childName),
                      const SizedBox(height: AppSpacing.md),
                      _buildParentSuggestionsCard(context, childName),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildParentActionRow(context),
      ],
    );
  }

  Widget _buildDailySummaryCard(
    BuildContext context,
    String childName,
    List<_DashboardActivity> activities,
  ) {
    final lastActivity = activities.isNotEmpty
        ? activities.first.time
        : '10:45 AM';

    return _DashboardCard(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final childDetails = Expanded(
            child: _ChildSummaryDetails(childName: childName),
          );
          final lastActivityCard = _LastActivityPill(time: lastActivity);

          if (constraints.maxWidth < 430) {
            return Column(
              children: [
                Row(
                  children: [
                    _ChildInitialAvatar(childName: childName),
                    const SizedBox(width: AppSpacing.md),
                    childDetails,
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Align(alignment: Alignment.centerLeft, child: lastActivityCard),
              ],
            );
          }

          return Row(
            children: [
              _ChildInitialAvatar(childName: childName),
              const SizedBox(width: AppSpacing.md),
              childDetails,
              lastActivityCard,
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatGrid(
    BuildContext context,
    List<HistoryEntry> entries,
    int activityCount,
  ) {
    final mealCount = entries
        .where(
          (entry) =>
              entry.type == FormType.nutrition &&
              (entry.data['meal'] as String? ?? '').isNotEmpty,
        )
        .length;
    final waterAmount = _latestHydration(entries);
    final stats = [
      _FeedStat(
        'Activities',
        activityCount.toString(),
        'Today',
        Icons.menu_book_rounded,
        context.colors.secondary,
        context.colors.secondaryLight,
      ),
      _FeedStat(
        'Meals',
        (mealCount == 0 ? 3 : mealCount).toString(),
        'Today',
        Icons.restaurant_rounded,
        context.colors.success,
        context.colors.successLight,
      ),
      _FeedStat(
        'Water',
        waterAmount,
        'Today',
        Icons.water_drop_rounded,
        context.colors.info,
        context.colors.infoLight,
      ),
      _FeedStat(
        'Sleep',
        '2h 15m',
        'Today',
        Icons.nightlight_round,
        const Color(0xFFF59E0B),
        context.colors.warningLight,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        final spacing = AppSpacing.md;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: stats.map((stat) {
            return SizedBox(
              width: itemWidth,
              child: _DashboardCard(
                backgroundColor: stat.tint.withValues(
                  alpha: context.isDarkMode ? 0.18 : 0.42,
                ),
                borderColor: stat.color.withValues(alpha: 0.18),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: stat.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(stat.icon, color: stat.color, size: 26),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            stat.value,
                            maxLines: 1,
                            style: context.textStyles.heading2.copyWith(
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            stat.caption,
                            style: context.textStyles.caption.copyWith(
                              color: context.colors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTodayActivitiesCard(
    BuildContext context,
    List<_DashboardActivity> activities,
  ) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: "Today's Activities",
            action: 'View All',
            actionColor: context.colors.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(activities.length, (index) {
            final activity = activities[index];
            return _DashboardActivityRow(
              activity: activity,
              isLast: index == activities.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPhotosCard(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: "Today's Photos",
            action: 'View All',
            actionColor: context.colors.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == 2 ? 0 : AppSpacing.sm,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/napping.jpeg',
                      height: 86,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PhotoDot(color: context.colors.secondary),
              _PhotoDot(color: context.colors.border),
              _PhotoDot(color: context.colors.border),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthSnapshotCard(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Growth Snapshot',
            action: 'View History',
            actionColor: context.colors.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _GrowthMetricCard(
                  icon: Icons.height_rounded,
                  label: 'Height',
                  value: '102',
                  unit: 'cm',
                  change: '+ 2 cm this month',
                  color: context.colors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _GrowthMetricCard(
                  icon: Icons.monitor_weight_rounded,
                  label: 'Weight',
                  value: '16',
                  unit: 'kg',
                  change: '+ 0.5 kg this month',
                  color: context.colors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context) {
    return _DashboardCard(
      backgroundColor: context.colors.warningLight.withValues(
        alpha: context.isDarkMode ? 0.16 : 0.42,
      ),
      borderColor: context.colors.warning.withValues(alpha: 0.26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Incident Report',
            action: 'View All',
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF97316),
            actionColor: context.colors.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.white.withValues(
                alpha: context.isDarkMode ? 0.04 : 0.58,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF97316).withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              'Minor bruise on left knee while playing.\nReported by Ms. Neha Sharma\n02:45 PM, Today',
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textDark,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard(BuildContext context, String childName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary, context.colors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.secondary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: context.colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Insight',
                      style: context.textStyles.heading3.copyWith(
                        color: context.colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$childName participated in more learning activities this week compared to last week.',
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colors.white,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: context.colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: context.colors.white,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentSuggestionsCard(BuildContext context, String childName) {
    return _DashboardCard(
      backgroundColor: context.colors.primaryLight.withValues(
        alpha: context.isDarkMode ? 0.16 : 0.38,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: context.colors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Parent Suggestions',
                      style: context.textStyles.heading3.copyWith(fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$childName enjoys puzzle and alphabet activities. Try simple word games at home to build vocabulary.',
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.textMedium,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.colors.white.withValues(
                alpha: context.isDarkMode ? 0.06 : 0.72,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.family_restroom_rounded,
              color: context.colors.primary,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard(BuildContext context) {
    final items = [
      _ProgressMetric(
        'Learning',
        0.85,
        context.colors.secondary,
        Icons.school_rounded,
      ),
      _ProgressMetric(
        'Nutrition',
        0.72,
        context.colors.success,
        Icons.apple_rounded,
      ),
      _ProgressMetric(
        'Hydration',
        0.90,
        context.colors.info,
        Icons.water_drop_rounded,
      ),
      _ProgressMetric(
        'Attendance',
        0.96,
        const Color(0xFFF97316),
        Icons.person_pin_circle_rounded,
      ),
    ];

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Weekly Progress',
            action: 'View Report',
            actionColor: context.colors.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(item.icon, color: item.color, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 86,
                    child: Text(
                      item.label,
                      style: context.textStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: item.value,
                        minHeight: 7,
                        backgroundColor: context.colors.bgMuted,
                        valueColor: AlwaysStoppedAnimation<Color>(item.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${(item.value * 100).round()}%',
                    style: context.textStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentActionRow(BuildContext context) {
    final actions = [
      _ParentAction(
        'Message Teacher',
        Icons.chat_bubble_rounded,
        context.colors.secondary,
        context.colors.secondaryLight,
      ),
      _ParentAction(
        'Attendance',
        Icons.event_available_rounded,
        context.colors.success,
        context.colors.successLight,
      ),
      _ParentAction(
        'Download Report',
        Icons.download_rounded,
        const Color(0xFFF97316),
        context.colors.warningLight,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 3 : 1;
        final spacing = AppSpacing.md;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: AppSpacing.sm,
          children: actions.map((action) {
            return SizedBox(
              width: width,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(action.icon, color: action.color),
                label: Text(
                  action.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: action.tint.withValues(
                    alpha: context.isDarkMode ? 0.16 : 0.44,
                  ),
                  side: BorderSide(color: action.color.withValues(alpha: 0.18)),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFeedDashboardSkeleton(BuildContext context) {
    return Column(
      children: [
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _SkeletonBlock(width: 180, height: 18),
              SizedBox(height: 16),
              _SkeletonBlock(width: double.infinity, height: 12),
              SizedBox(height: 10),
              _SkeletonBlock(width: 220, height: 12),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _FeedTimelineSkeleton(),
      ],
    );
  }

  List<_DashboardActivity> _mockDashboardActivities(String childName) {
    return [
      _DashboardActivity(
        'Learning Activity',
        'Alphabet practice completed',
        '10:45 AM',
        Icons.menu_book_rounded,
        const Color(0xFF6366F1),
        0,
      ),
      _DashboardActivity(
        'Photo Uploaded',
        '2 new classroom photos',
        '10:30 AM',
        Icons.camera_alt_rounded,
        const Color(0xFFEC4899),
        0,
      ),
      _DashboardActivity(
        'Meal Update',
        'Finished 80% breakfast',
        '09:15 AM',
        Icons.restaurant_rounded,
        const Color(0xFFF59E0B),
        0.80,
      ),
      _DashboardActivity(
        'Water Intake',
        '250ml consumed',
        '08:45 AM',
        Icons.water_drop_rounded,
        const Color(0xFF38BDF8),
        0,
      ),
      _DashboardActivity(
        'Nap Started',
        '$childName is taking a nap',
        '12:30 PM',
        Icons.nightlight_round,
        const Color(0xFF8B5CF6),
        0,
      ),
      _DashboardActivity(
        'Health Check',
        'Temperature normal',
        '04:00 PM',
        Icons.favorite_rounded,
        const Color(0xFFEC4899),
        98.4,
      ),
    ];
  }

  List<_DashboardActivity> _activitiesFromHistory(List<HistoryEntry> entries) {
    final sorted = [...entries]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(7).map((entry) {
      final time = DateFormat('hh:mm a').format(entry.createdAt);
      if (entry.type == FormType.nutrition) {
        final meal = entry.data['meal'] as String? ?? '';
        final hydration = entry.data['hydration'] as String? ?? '';
        if (hydration.isNotEmpty && meal.isEmpty) {
          return _DashboardActivity(
            'Water Intake',
            '$hydration consumed',
            time,
            Icons.water_drop_rounded,
            const Color(0xFF38BDF8),
            0,
          );
        }
        return _DashboardActivity(
          'Meal Update',
          meal.isEmpty ? 'Meal logged' : meal,
          time,
          Icons.restaurant_rounded,
          const Color(0xFFF59E0B),
          0,
        );
      }
      if (entry.type == FormType.growth) {
        return _DashboardActivity(
          'Growth Update',
          'New growth measurement added',
          time,
          Icons.trending_up_rounded,
          const Color(0xFF6366F1),
          0,
        );
      }
      if (entry.type == FormType.incident) {
        return _DashboardActivity(
          'Incident Report',
          entry.data['title'] as String? ?? 'Incident logged',
          time,
          Icons.warning_amber_rounded,
          const Color(0xFFF97316),
          0,
        );
      }
      final title = entry.data['activity_name'] as String? ?? 'Activity Update';
      final icon = title.toLowerCase().contains('nap')
          ? Icons.nightlight_round
          : Icons.menu_book_rounded;
      return _DashboardActivity(
        title,
        entry.data['notes'] as String? ?? 'Activity completed',
        time,
        icon,
        const Color(0xFF6366F1),
        0,
      );
    }).toList();
  }

  String _latestHydration(List<HistoryEntry> entries) {
    for (final entry in entries.reversed) {
      if (entry.type == FormType.nutrition) {
        final hydration = entry.data['hydration'] as String? ?? '';
        if (hydration.isNotEmpty) return hydration;
      }
    }
    return '1200 ml';
  }

  // Feed Section Header
  Widget _buildFeedHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Activity Feed',
          style: context.textStyles.heading1.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: context.colors.textDark,
          ),
        ),
        const Spacer(),
        Text(
          'Today',
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Mock Timeline matching template
  // ignore: unused_element
  Widget _buildMockTimeline(BuildContext context, {required bool isLiam}) {
    return Column(
      children: [
        _buildTimelineItem(
          context: context,
          time: '12:30 PM',
          badgeBg: const Color(0xFFDCEFFA),
          icon: Icons.nightlight_round,
          iconColor: const Color(0xFF285C7A),
          card: _buildNapCard(context),
          isLast: false,
        ),
        _buildTimelineItem(
          context: context,
          time: '11:15 AM',
          badgeBg: const Color(0xFFC7F3FD),
          icon: Icons.water_drop_rounded,
          iconColor: const Color(0xFF246C8F),
          card: _buildHydrationCard(context),
          isLast: false,
        ),
        _buildTimelineItem(
          context: context,
          time: '09:45 AM',
          badgeBg: const Color(0xFFC3F3E8),
          icon: Icons.restaurant_rounded,
          iconColor: const Color(0xFF267D69),
          card: _buildSnackCard(context, isLiam: isLiam),
          isLast: true,
        ),
      ],
    );
  }

  // Real Database Timeline mapping
  Widget _buildRealTimeline(BuildContext context, List<HistoryEntry> entries) {
    return Column(
      children: List.generate(entries.length, (index) {
        final entry = entries[index];
        final isLast = index == entries.length - 1;
        final timeStr = DateFormat('hh:mm a').format(entry.createdAt);

        if (entry.type == FormType.activity) {
          final actName = entry.data['activity_name'] as String? ?? '';
          final isNap =
              actName.toLowerCase().contains('nap') ||
              actName.toLowerCase().contains('sleep');

          return _buildTimelineItem(
            context: context,
            time: timeStr,
            badgeBg: isNap ? const Color(0xFFDCEFFA) : const Color(0xFFE2E8F0),
            icon: isNap ? Icons.nightlight_round : Icons.run_circle_rounded,
            iconColor: isNap
                ? const Color(0xFF285C7A)
                : const Color(0xFF4A5568),
            card: isNap
                ? _buildNapCard(
                    context,
                    time: timeStr,
                    notes: entry.data['notes'] as String?,
                  )
                : _buildGenericCard(
                    context,
                    actName,
                    entry.data['notes'] as String?,
                  ),
            isLast: isLast,
          );
        } else if (entry.type == FormType.nutrition) {
          final meal = entry.data['meal'] as String? ?? '';
          final hydration = entry.data['hydration'] as String? ?? '';

          if (hydration.isNotEmpty && meal.isEmpty) {
            return _buildTimelineItem(
              context: context,
              time: timeStr,
              badgeBg: const Color(0xFFC7F3FD),
              icon: Icons.water_drop_rounded,
              iconColor: const Color(0xFF246C8F),
              card: _buildHydrationCard(
                context,
                time: timeStr,
                amount: hydration,
              ),
              isLast: isLast,
            );
          } else {
            return _buildTimelineItem(
              context: context,
              time: timeStr,
              badgeBg: const Color(0xFFC3F3E8),
              icon: Icons.restaurant_rounded,
              iconColor: const Color(0xFF267D69),
              card: _buildSnackCard(context, time: timeStr, meal: meal),
              isLast: isLast,
            );
          }
        } else if (entry.type == FormType.growth) {
          final ht = entry.data['height']?.toString() ?? '-';
          final wt = entry.data['weight']?.toString() ?? '-';
          return _buildTimelineItem(
            context: context,
            time: timeStr,
            badgeBg: const Color(0xFFFDE8E8),
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF9B1C1C),
            card: _buildGenericCard(
              context,
              'Growth Entry',
              'Height: ${ht}cm, Weight: ${wt}kg',
            ),
            isLast: isLast,
          );
        } else {
          // Incident
          final title = entry.data['title'] as String? ?? 'Incident';
          final desc = entry.data['description'] as String? ?? '';
          return _buildTimelineItem(
            context: context,
            time: timeStr,
            badgeBg: const Color(0xFFFEF3C7),
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFD97706),
            card: _buildGenericCard(context, title, desc, isDanger: true),
            isLast: isLast,
          );
        }
      }),
    );
  }

  // Custom Reusable Timeline Row
  Widget _buildTimelineItem({
    required BuildContext context,
    required String time,
    required Color badgeBg,
    required IconData icon,
    required Color iconColor,
    required Widget card,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline stem and node
        SizedBox(
          width: 42,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : context.colors.divider,
                ),
              ),
              // Stop line at node center if last
              if (isLast)
                Positioned(
                  top: 0,
                  bottom: 21,
                  child: Container(width: 2, color: context.colors.divider),
                ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: badgeBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Timeline content card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: card,
          ),
        ),
      ],
    );
  }

  // Card UI Components
  Widget _buildNapCard(
    BuildContext context, {
    String time = '12:30 PM',
    String? notes,
  }) {
    final displayNotes = notes ?? 'Fell asleep quickly with white noise.';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Nap Time',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: context.colors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'START',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time.split(' ').first,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(height: 1.5, color: context.colors.divider),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'END',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '- : -',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayNotes,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationCard(
    BuildContext context, {
    String time = '11:15 AM',
    String? amount,
  }) {
    final displayAmt = amount ?? '300 / 500ml';
    double pct = 0.6;
    if (amount != null) {
      try {
        final cleaned = amount.replaceAll('ml', '').trim();
        if (cleaned.contains('/')) {
          final parts = cleaned.split('/');
          final cur = double.parse(parts[0].trim());
          final tot = double.parse(parts[1].trim());
          pct = (cur / tot).clamp(0.0, 1.0);
        } else {
          final val = double.parse(cleaned);
          pct = (val / 500.0).clamp(0.0, 1.0);
        }
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hydration',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: context.colors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Water',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                displayAmt,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: context.colors.bgMuted,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnackCard(
    BuildContext context, {
    String time = '09:45 AM',
    String? meal,
    bool isLiam = true,
  }) {
    final mealText = meal ?? '';
    final hasMealText = mealText.isNotEmpty;

    // Determine meal chips
    List<String> items = [];
    String note = '';

    if (hasMealText) {
      items = mealText.split(',').map((e) => e.trim()).toList();
      note = 'Finished most of the logged items.';
    } else {
      items = ['Oatmeal', 'Fruit'];
      note = isLiam
          ? 'Finished all of his apple slices and most of the oatmeal.'
          : 'Finished the meal.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Morning Snack',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: context.colors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((item) {
              IconData icon = Icons.lunch_dining_rounded;
              if (item.toLowerCase().contains('oatmeal') ||
                  item.toLowerCase().contains('cereal') ||
                  item.toLowerCase().contains('porridge')) {
                icon = Icons.soup_kitchen_rounded;
              } else if (item.toLowerCase().contains('fruit') ||
                  item.toLowerCase().contains('apple') ||
                  item.toLowerCase().contains('banana')) {
                icon = Icons.apple_rounded;
              } else if (item.toLowerCase().contains('milk') ||
                  item.toLowerCase().contains('water') ||
                  item.toLowerCase().contains('juice')) {
                icon = Icons.local_drink_rounded;
              }
              return _buildFoodChip(context, item, icon);
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            note,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericCard(
    BuildContext context,
    String title,
    String? description, {
    bool isDanger = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isDanger ? context.colors.danger : context.colors.textDark,
            ),
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textMedium,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.bgMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.colors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: context.colors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // Quick Action Sheets
  void _showPlusActions(
    BuildContext context,
    String childId,
    String childName,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                childName,
                style: context.textStyles.heading2.copyWith(
                  color: context.colors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Quick Actions',
                style: context.textStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.push(
                    '/parent/children/$childId?name=${Uri.encodeComponent(childName)}',
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.child_care_rounded),
                    SizedBox(width: 8),
                    Text('View Child Profile'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  side: BorderSide(color: context.colors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/parent/children/add');
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded),
                    SizedBox(width: 8),
                    Text('Register a New Child'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: context.colors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChildInitialAvatar extends StatelessWidget {
  const _ChildInitialAvatar({required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: context.colors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.white, width: 4),
      ),
      alignment: Alignment.center,
      child: Text(
        childName.isNotEmpty ? childName[0].toUpperCase() : 'C',
        style: context.textStyles.heading1.copyWith(
          color: context.colors.primary,
          fontSize: 28,
        ),
      ),
    );
  }
}

class _ChildSummaryDetails extends StatelessWidget {
  const _ChildSummaryDetails({required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          childName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.heading2.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          '4 Years - Nursery A',
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colors.textMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: context.colors.successLight,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: context.colors.success.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: context.colors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Currently Checked In',
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LastActivityPill extends StatelessWidget {
  const _LastActivityPill({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, color: context.colors.secondary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Activity', style: context.textStyles.caption),
              Text(
                time,
                style: context.textStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor ?? context.colors.border.withValues(alpha: 0.58),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.16 : 0.045,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.actionColor,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String action;
  final Color actionColor;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor ?? context.colors.primary, size: 21),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.heading3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          action,
          style: context.textStyles.bodySmall.copyWith(
            color: actionColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DashboardActivityRow extends StatelessWidget {
  const _DashboardActivityRow({required this.activity, required this.isLast});

  final _DashboardActivity activity;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.secondary,
                      width: 2.5,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: context.colors.secondary.withValues(alpha: 0.28),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  activity.color.withValues(alpha: 0.92),
                  activity.color.withValues(alpha: 0.70),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(activity.icon, color: context.colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: context.colors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          activity.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodySmall.copyWith(
                            color: context.colors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        activity.time,
                        style: context.textStyles.caption.copyWith(
                          color: context.colors.textMedium,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (activity.badgeValue > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.successLight,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: context.colors.success.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Text(
                            activity.badgeValue > 10
                                ? '${activity.badgeValue.toStringAsFixed(1)} F'
                                : '${(activity.badgeValue * 100).round()}%',
                            style: context.textStyles.caption.copyWith(
                              color: context.colors.success,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthMetricCard extends StatelessWidget {
  const _GrowthMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.change,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String change;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.bgLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RichText(
            text: TextSpan(
              style: context.textStyles.bodySmall,
              children: [
                TextSpan(
                  text: value,
                  style: context.textStyles.heading3.copyWith(fontSize: 20),
                ),
                TextSpan(text: ' $unit'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.caption.copyWith(
              color: context.colors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.64,
              minHeight: 5,
              backgroundColor: context.colors.bgMuted,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoDot extends StatelessWidget {
  const _PhotoDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DashboardActivity {
  const _DashboardActivity(
    this.title,
    this.subtitle,
    this.time,
    this.icon,
    this.color,
    this.badgeValue,
  );

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final double badgeValue;
}

class _FeedStat {
  const _FeedStat(
    this.label,
    this.value,
    this.caption,
    this.icon,
    this.color,
    this.tint,
  );

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;
  final Color tint;
}

class _ProgressMetric {
  const _ProgressMetric(this.label, this.value, this.color, this.icon);

  final String label;
  final double value;
  final Color color;
  final IconData icon;
}

class _ParentAction {
  const _ParentAction(this.label, this.icon, this.color, this.tint);

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
}

class _FeedTimelineSkeleton extends StatelessWidget {
  const _FeedTimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SkeletonTimelineItem(
          badgeColor: Color(0xFFDCEFFA),
          height: 154,
          isLast: false,
        ),
        _SkeletonTimelineItem(
          badgeColor: Color(0xFFC7F3FD),
          height: 118,
          isLast: false,
        ),
        _SkeletonTimelineItem(
          badgeColor: Color(0xFFC3F3E8),
          height: 142,
          isLast: true,
        ),
      ],
    );
  }
}

class _SkeletonTimelineItem extends StatelessWidget {
  const _SkeletonTimelineItem({
    required this.badgeColor,
    required this.height,
    required this.isLast,
  });

  final Color badgeColor;
  final double height;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 42,
          height: height + 24,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                bottom: isLast ? height + 3 : 0,
                child: Container(width: 2, color: context.colors.divider),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(
                    alpha: context.isDarkMode ? 0.25 : 1,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _SkeletonCard(height: height),
          ),
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SkeletonBlock(width: 98, height: 16),
              const Spacer(),
              _SkeletonBlock(
                width: 48,
                height: 10,
                color: context.colors.bgMuted,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SkeletonBlock(width: double.infinity, height: 12),
          const SizedBox(height: 10),
          _SkeletonBlock(width: 150, height: 12, color: context.colors.bgMuted),
          const Spacer(),
          FractionallySizedBox(
            widthFactor: 0.62,
            child: _SkeletonBlock(height: 12, color: context.colors.bgMuted),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, this.width, this.color});

  final double height;
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color:
            color ??
            context.colors.border.withValues(
              alpha: context.isDarkMode ? 0.28 : 0.55,
            ),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

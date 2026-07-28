import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/providers/theme_provider.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

/// Shared across all roles — dark mode, language, display preferences.
/// Navigate here via context.push('/app-settings') from any settings screen.
class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {

  String _language = 'English';
  bool _compactMode = false;

  static const _languages = [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('App Settings', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Appearance ──────────────────────────────────────────
            _sectionLabel('Appearance'),
            _card([
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: context.colors.textDark.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Icon(Icons.dark_mode_outlined,
                          color: context.colors.textDark, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('Dark Mode', style: context.textStyles.bodyLarge),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(
                      left: AppSpacing.md + AppSpacing.xs + 18,
                      top: 2),
                  child: Text('Toggle application theme',
                      style: context.textStyles.bodySmall),
                ),
                activeThumbColor: Theme.of(context).switchTheme.thumbColor?.resolve({WidgetState.selected}),
                activeTrackColor: Theme.of(context).switchTheme.trackColor?.resolve({WidgetState.selected}),
                value: isDarkMode,
                onChanged: (val) {
                  ref.read(themeModeProvider.notifier).state = 
                      val ? ThemeMode.dark : ThemeMode.light;
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: context.colors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Icon(Icons.view_compact_outlined,
                          color: context.colors.primary, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('Compact Mode', style: context.textStyles.bodyLarge),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(
                      left: AppSpacing.md + AppSpacing.xs + 18,
                      top: 2),
                  child: Text('Reduce spacing in lists',
                      style: context.textStyles.bodySmall),
                ),
                activeThumbColor: Theme.of(context).switchTheme.thumbColor?.resolve({WidgetState.selected}),
                activeTrackColor: Theme.of(context).switchTheme.trackColor?.resolve({WidgetState.selected}),
                value: _compactMode,
                onChanged: (val) => setState(() => _compactMode = val),
              ),
            ]),

            const SizedBox(height: AppSpacing.lg),

            // ── Language ─────────────────────────────────────────────
            _sectionLabel('Language'),
            _card([
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: context.colors.secondaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Icon(Icons.language_rounded,
                          color: context.colors.secondary, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: Text('Display Language',
                            style: context.textStyles.bodyLarge)),
                    DropdownButton<String>(
                      value: _language,
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down_rounded,
                          color: context.colors.textMuted),
                      style: context.textStyles.bodyMedium,
                      items: _languages
                          .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text(l,
                                  style: context.textStyles.bodyMedium)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _language = v);
                      },
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: AppSpacing.xxl),

            // Version info
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '...';
                return Center(
                  child: Text(
                    'TinySteps v$version',
                    style: context.textStyles.caption
                        .copyWith(color: context.colors.textMuted),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(
          label.toUpperCase(),
          style: context.textStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.colors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(children: children),
      );
}

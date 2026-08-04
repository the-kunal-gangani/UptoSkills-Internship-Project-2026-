import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class TeacherFAQScreen extends StatelessWidget {
  const TeacherFAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I mark attendance?',
        'a': 'Open My Schedule, tap the session for today, then press "Start Session" when you arrive and "End Session" when the session ends.',
      },
      {
        'q': 'How do I log a child\'s activity?',
        'a': 'Go to the child detail page and tap any activity card (Meals, Growth, Incidents) to add a new log entry.',
      },
      {
        'q': 'Can I edit child details?',
        'a': 'Only parents or admin can edit child details. You can view full child info including allergies from the child detail page.',
      },
      {
        'q': 'How do I contact support?',
        'a': 'Use email or WhatsApp from Help & Support in your settings.',
      },
      {
        'q': 'Why is my account pending?',
        'a': 'Staff accounts need admin approval before you can access sessions.',
      },
      {
        'q': 'What if a parent changes the session time?',
        'a': 'You will see updated session details in your Schedule. Contact admin if you have a conflict.',
      },
    ];

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('FAQs', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: faqs.length,
        itemBuilder: (context, index) =>
            _FaqCard(question: faqs[index]['q']!, answer: faqs[index]['a']!),
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqCard({required this.question, required this.answer});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool isOpen = false;
  static const _accentOrange = Color(0xFFFF7A66);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isOpen
              ? _accentOrange
              : context.colors.border.withValues(alpha: 0.5),
        ),
        boxShadow: AppShadows.card,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => setState(() => isOpen = !isOpen),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: context.textStyles.labelBold.copyWith(
                        color: isOpen ? _accentOrange : context.colors.textDark,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: _accentOrange,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    widget.answer,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
                crossFadeState: isOpen
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

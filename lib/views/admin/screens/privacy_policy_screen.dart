import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: context.textStyles.heading3),
    );
  }

  Widget _sectionBody(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(text, style: context.textStyles.bodyMedium),
    );
  }

  Widget _cardSection(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Privacy Matters', style: context.textStyles.heading2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We are committed to protecting the privacy of every child, parent, caregiver, and administrator using TinySteps.',
              style: context.textStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _cardSection(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Who We Are'),
                  _sectionBody(
                    context,
                    'TinySteps is a secure personal in-home daycare management platform designed to connect Parents, Caregivers (Staff), and Administrators in one place. It enables real-time tracking of attendance, daily activities, meals, and personalised child development insights for children aged 0–5 years.',
                  ),
                ],
              ),
            ),
            _cardSection(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '1. Information We Collect'),
                  _sectionBody(
                    context,
                    'We collect essential data such as user details, child profiles, attendance logs, and activity updates. Sensitive information like medical details is collected only when necessary and handled with strict security.',
                  ),
                ],
              ),
            ),
            _cardSection(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '2. How We Use Information'),
                  _sectionBody(
                    context,
                    'Your data is used to provide core daycare services including attendance tracking, activity updates, personalized content, and secure communication between users.',
                  ),
                ],
              ),
            ),
            _cardSection(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '3. Privacy for Parents'),
                  _sectionBody(
                    context,
                    'Parents can only access their own child\'s data. This includes attendance, meals, activities, and care updates. No parent can view another child\'s information under any circumstance.',
                  ),
                ],
              ),
            ),
            _cardSection(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '4. Privacy for Caregivers'),
                  _sectionBody(
                    context,
                    'Caregivers (Staff) can access and update data only for children assigned to them. They cannot access administrative controls or unrelated child records.',
                  ),
                ],
              ),
            ),
            _cardSection(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '5. Privacy for Administrators'),
                  _sectionBody(
                    context,
                    'Administrators manage user accounts, approvals, and system access. They have controlled access to data strictly for operational purposes and are responsible for maintaining platform security.',
                  ),
                ],
              ),
            ),
            _cardSection(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '6. Data Security'),
                  _sectionBody(
                    context,
                    'TinySteps uses secure cloud infrastructure, encryption, and role-based access control to protect all data. Unauthorized access is strictly prevented through referral-based account creation.',
                  ),
                ],
              ),
            ),
            _cardSection(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '7. Data Sharing'),
                  _sectionBody(
                    context,
                    'We do not sell, trade, or share your personal data with third parties. All information is used only within TinySteps to provide core functionality.',
                  ),
                ],
              ),
            ),
            _cardSection(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '8. User Rights'),
                  _sectionBody(
                    context,
                    'Users can request updates or deletion of their data. Administrators can manage and ensure data accuracy within the system.',
                  ),
                ],
              ),
            ),
            _cardSection(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, '9. Policy Updates'),
                  _sectionBody(
                    context,
                    'This policy may be updated as TinySteps evolves. Users will be notified of any significant changes.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Last updated: 2026',
                style: context.textStyles.bodySmall,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

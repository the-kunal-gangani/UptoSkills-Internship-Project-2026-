
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class SafetyScreen extends ConsumerWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              backgroundColor: context.colors.primary.withValues(alpha: .15),
              child: Text(
                initial,
                style: context.textStyles.labelBold.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(firstName, style: context.textStyles.labelBold),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Safety & Security', style: context.textStyles.heading2),
            const SizedBox(height: 4),
            Text(
              'Real-time monitoring and safety updates.',
              style: context.textStyles.bodySmall,
            ),

            const SizedBox(height: 20),

            // LIVE CAMERA
            _SectionTitle(
              title: 'Live Camera',
              icon: Icons.videocam_rounded,
              color: Colors.red,
            ),

            const SizedBox(height: 8),

            _SafetyCard(
              context: context,
              child: Column(
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1588072432836-e10032774350',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Colors.red, size: 10),
                      const SizedBox(width: 6),
                      Text(
                        'Main Play Area',
                        style: context.textStyles.labelBold,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SafetyCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Camera Views", style: context.textStyles.labelBold),
                  const SizedBox(height: 12),
                  _cameraTile(context, 'Main Play Area', true),
                  _cameraTile(context, 'Classroom', false),
                  _cameraTile(context, 'Outdoor Playground', false),
                  _cameraTile(context, 'Dining Area', false),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _SafetyCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Child Is Safe',
                          style: context.textStyles.labelBold,
                        ),
                        const SizedBox(height: 12),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: context.colors.primaryLight,
                          child: Text("👦", style: context.textStyles.heading2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Main Play Area",
                          style: context.textStyles.labelBold,
                        ),
                        Text(
                          "Safely Active",
                          style: context.textStyles.bodySmall.copyWith(
                            color: context.colors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SafetyCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safety Score',
                          style: context.textStyles.labelBold,
                        ),
                        const SizedBox(height: 8),
                        Text("98 / 100", style: context.textStyles.heading2),
                        Text("Excellent", style: context.textStyles.bodySmall),
                        const SizedBox(height: 12),
                        _checkItem(context, "Door Locked"),
                        _checkItem(context, "CCTV Online"),
                        _checkItem(context, "Staff Present"),
                        _checkItem(context, "Emergency Exit Clear"),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SectionTitle(title: "Today's Activity", icon: Icons.history),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _activity(context, Icons.login, "Checked In", "8:00 AM"),
                _activity(context, Icons.fastfood, "Snack", "10:30 AM"),
                _activity(context, Icons.restaurant, "Lunch", "12:15 PM"),
                _activity(context, Icons.bed, "Nap", "2:30 PM"),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _gridCards(context, "Authorized Pickup", [
                    "Father",
                    "Mother",
                    "Grandparent",
                  ]),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _gridCards(context, "Staff On Duty", [
                    "Sarah",
                    "Emma",
                    "David",
                  ]),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _gridCards(context, "Today's Visitors", [
                    "Maintenance",
                    "Vendor",
                    "Food Delivery",
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SafetyCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Health Monitoring",
                    style: context.textStyles.labelBold,
                  ),
                  const SizedBox(height: 12),
                  _statusLine(context, "Temperature", "Normal"),
                  _statusLine(context, "Heart Rate", "Normal"),
                  _statusLine(context, "Food Alert", "Active"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SafetyCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Health Monitoring",
                          style: context.textStyles.labelBold,
                        ),
                        const SizedBox(height: 12),

                        _statusLine(context, "Temperature", "Normal"),

                        _statusLine(context, "Heart Rate", "Normal"),

                        _statusLine(context, "Food Alert", "Active"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _SafetyCard(
                    context: context,
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: true,
                          onChanged: (_) {},
                          title: const Text("Check-in Alert"),
                        ),
                        SwitchListTile(
                          value: true,
                          onChanged: (_) {},
                          title: const Text("Pickup Alert"),
                        ),
                        SwitchListTile(
                          value: true,
                          onChanged: (_) {},
                          title: const Text("Medication Reminder"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone),
                    label: const Text("Call School"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(55),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.warning),
                    label: const Text("Panic Alert"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(55),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.local_hospital),
                    label: const Text("Medical"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(55),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _SafetyCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Our Commitment To Safety",
                    style: context.textStyles.labelBold,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      Chip(label: Text("Certified Facility")),
                      Chip(label: Text("24/7 CCTV")),
                      Chip(label: Text("Verified Staff")),
                      Chip(label: Text("Data Protection")),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _cameraTile(BuildContext context, String title, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? context.colors.primaryLight : context.colors.bgMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(title),
    );
  }

  Widget _checkItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: context.colors.success),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _activity(
    BuildContext context,
    IconData icon,
    String title,
    String time,
  ) {
    return Column(
      children: [
        CircleAvatar(radius: 20, child: Icon(icon, size: 18)),
        const SizedBox(height: 6),
        Text(title, style: context.textStyles.caption),
        Text(time, style: context.textStyles.caption),
      ],
    );
  }

  Widget _gridCards(BuildContext context, String title, List<String> items) {
    return _SafetyCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textStyles.labelBold),
          const SizedBox(height: 12),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(e),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusLine(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: context.textStyles.labelBold),
        ],
      ),
    );
  }

}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const _SectionTitle({required this.title, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color ?? context.colors.primary),
        const SizedBox(width: 8),
        Text(title, style: context.textStyles.labelBold),
      ],
    );
  }
}

class _SafetyCard extends StatelessWidget {
  final Widget child;
  final BuildContext context;

  const _SafetyCard({required this.child, required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: this.context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: this.context.colors.border),
      ),
      child: child,
    );
  }
}

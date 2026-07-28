import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityFormScreen extends StatefulWidget {
  final String childId;
  final String? childName;

  const ActivityFormScreen({super.key, required this.childId, this.childName});

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final activityController = TextEditingController();
  final sleepController = TextEditingController();
  final moodController = TextEditingController();
  final notesController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    activityController.dispose();
    sleepController.dispose();
    moodController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> saveActivity() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await supabase.from('activities').insert({
        'child_id': widget.childId,
        'activity_name': activityController.text.trim(),
        'sleep_hours': sleepController.text.trim(),
        'mood': moodController.text.trim(),
        'notes': notesController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) setState(() => loading = false);
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.childName != null
              ? '${widget.childName} – Activity'
              : 'Activity Form',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _field('Activity Name', activityController),
              _field('Sleep Duration', sleepController),
              _field('Mood', moodController),
              _field('Caregiver Notes', notesController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : saveActivity,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Save Activity'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

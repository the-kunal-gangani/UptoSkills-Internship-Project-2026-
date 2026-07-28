import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IncidentFormScreen extends StatefulWidget {
  final String childId;
  final String? childName;

  const IncidentFormScreen({super.key, required this.childId, this.childName});

  @override
  State<IncidentFormScreen> createState() => _IncidentFormScreenState();
}

class _IncidentFormScreenState extends State<IncidentFormScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final actionController = TextEditingController();

  String _severity = 'Minor';
  bool loading = false;

  static const _severityOptions = ['Minor', 'Moderate', 'Serious'];

  static Color _severityColor(String s) => switch (s) {
        'Serious' => Colors.red,
        'Moderate' => Colors.orange,
        _ => Colors.green,
      };

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    actionController.dispose();
    super.dispose();
  }

  Future<void> saveIncident() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await supabase.from('incidents').insert({
        'child_id': widget.childId,
        'title': titleController.text.trim(),
        'severity': _severity,
        'description': descriptionController.text.trim(),
        'action_taken': actionController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incident report saved ✓'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.childName != null
              ? '${widget.childName} – Incident'
              : 'New Incident Report',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title ─────────────────────────────────────
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Brief description of the incident',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.report_problem_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // ── Severity ──────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _severity,
                    isExpanded: true,
                    hint: const Text('Severity Level'),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    onChanged: (val) {
                      if (val != null) setState(() => _severity = val);
                    },
                    items: _severityOptions.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _severityColor(s),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(s),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Description ───────────────────────────────
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'What happened? *',
                  hintText: 'Describe the incident in detail…',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Please describe the incident'
                        : null,
              ),
              const SizedBox(height: 16),

              // ── Action taken ──────────────────────────────
              TextFormField(
                controller: actionController,
                decoration: const InputDecoration(
                  labelText: 'Action Taken',
                  hintText: 'What steps were taken to address this?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 28),

              // ── Severity badge preview ────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _severityColor(_severity).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _severityColor(_severity).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: _severityColor(_severity),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Severity: $_severity',
                      style: TextStyle(
                        color: _severityColor(_severity),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Save button ───────────────────────────────
              FilledButton.icon(
                onPressed: loading ? null : saveIncident,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(loading ? 'Saving…' : 'Save Incident Report'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _severity == 'Serious'
                      ? Colors.red
                      : _severity == 'Moderate'
                          ? Colors.orange
                          : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

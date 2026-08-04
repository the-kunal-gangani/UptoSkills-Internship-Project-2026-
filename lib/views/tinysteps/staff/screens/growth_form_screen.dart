import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GrowthFormScreen extends StatefulWidget {
  final String childId;
  final String? childName;

  const GrowthFormScreen({super.key, required this.childId, this.childName});

  @override
  State<GrowthFormScreen> createState() => _GrowthFormScreenState();
}

class _GrowthFormScreenState extends State<GrowthFormScreen> {
  final supabase = Supabase.instance.client;

  final weightController = TextEditingController();
  final heightController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  Future<void> saveGrowth() async {
    setState(() => loading = true);

    try {
      await supabase.from('growth_records').insert({
        'child_id': widget.childId,
        'weight': weightController.text.trim(),
        'height': heightController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Growth report saved successfully')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.childName != null
              ? '${widget.childName} – Growth'
              : 'Growth Report',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Weight',
                hintText: 'Enter weight (kg)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: heightController,
              decoration: const InputDecoration(
                labelText: 'Height',
                hintText: 'Enter height (cm)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveGrowth,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

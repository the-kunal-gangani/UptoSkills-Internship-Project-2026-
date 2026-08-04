import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NutritionFormScreen extends StatefulWidget {
  final String childId;
  final String? childName;

  const NutritionFormScreen({super.key, required this.childId, this.childName});

  @override
  State<NutritionFormScreen> createState() => _NutritionFormScreenState();
}

class _NutritionFormScreenState extends State<NutritionFormScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final mealController = TextEditingController();
  final hydrationController = TextEditingController();
  final notesController = TextEditingController();

  int _solidMeals = 0;
  int _appetiteLevel = 3;
  bool loading = false;

  @override
  void dispose() {
    mealController.dispose();
    hydrationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> saveNutrition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await supabase.from('nutrition_records').insert({
        'child_id': widget.childId,
        'meal': mealController.text.trim(),
        'hydration': hydrationController.text.trim(),
        'solid_meals_count': _solidMeals,
        'appetite_level': _appetiteLevel,
        'notes': notesController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nutrition record saved ✓'),
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
              ? '${widget.childName} – Nutrition'
              : 'Nutrition Record',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Meal ─────────────────────────────────────
              TextFormField(
                controller: mealController,
                decoration: const InputDecoration(
                  labelText: 'Meal *',
                  hintText: 'e.g. Lunch — rice, dal, vegetables',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please describe the meal' : null,
              ),
              const SizedBox(height: 16),

              // ── Hydration ─────────────────────────────────
              TextFormField(
                controller: hydrationController,
                decoration: const InputDecoration(
                  labelText: 'Hydration (ml)',
                  hintText: 'e.g. 200',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.water_drop_rounded),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // ── Solid meals stepper ───────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.set_meal_rounded),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Solid Meals',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      onPressed: _solidMeals > 0
                          ? () => setState(() => _solidMeals--)
                          : null,
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '$_solidMeals',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _solidMeals++),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Appetite level ────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rate_rounded),
                        const SizedBox(width: 12),
                        const Text(
                          'Appetite Level',
                          style: TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        Text(
                          '$_appetiteLevel / 5',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return IconButton(
                          icon: Icon(
                            i < _appetiteLevel ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () =>
                              setState(() => _appetiteLevel = i + 1),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Notes ─────────────────────────────────────
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any additional observations…',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 28),

              // ── Save button ───────────────────────────────
              FilledButton.icon(
                onPressed: loading ? null : saveNutrition,
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
                label: Text(loading ? 'Saving…' : 'Save Nutrition Record'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

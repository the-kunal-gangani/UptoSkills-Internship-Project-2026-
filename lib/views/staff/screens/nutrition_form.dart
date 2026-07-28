import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NutritionForm extends StatefulWidget {
  const NutritionForm({super.key});

  @override
  State<NutritionForm> createState() => _NutritionFormState();
}

class _NutritionFormState extends State<NutritionForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _milkController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  int _solidMealsCount = 0;
  int _appetiteLevel = 3; // Default middle rating out of 5

  @override
  void dispose() {
    _dateController.dispose();
    _milkController.dispose();
    _waterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker Field
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectDate(context),
                validator: (val) =>
                    val!.isEmpty ? 'Please select a date' : null,
              ),
              const SizedBox(height: 16),

              // Milk Intake Field
              TextFormField(
                controller: _milkController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Milk Intake (ml or oz)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter milk intake' : null,
              ),
              const SizedBox(height: 16),

              // Water Intake Field
              TextFormField(
                controller: _waterController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Water Intake (ml or oz)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter water intake' : null,
              ),
              const SizedBox(height: 20),

              // Solid Meals Count (Stepper Layout)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Solid Meals Count',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _solidMealsCount > 0
                            ? () => setState(() => _solidMealsCount--)
                            : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        '$_solidMealsCount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _solidMealsCount++),
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Appetite Level (Rating Layout)
              const Text(
                'Appetite Level',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _appetiteLevel ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _appetiteLevel = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Notes Textarea
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process / Save data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nutrition data saved successfully!'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save Nutrition Form',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

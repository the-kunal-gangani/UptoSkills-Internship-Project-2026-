import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class ParentChildrenState {
  final bool isLoading;
  final bool isSaving;
  final List<dynamic> children;
  final String? errorMessage;
  final DateTime? selectedDob;
  final DateTime? editDob;
  final String selectedGender;
  final String editGender;
  final String bloodGroup;

  const ParentChildrenState({
    this.isLoading = true,
    this.isSaving = false,
    this.children = const [],
    this.errorMessage,
    this.selectedDob,
    this.editDob,
    this.selectedGender = 'Male',
    this.editGender = 'Male',
    this.bloodGroup = '',
  });

  ParentChildrenState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<dynamic>? children,
    String? errorMessage,
    bool clearError = false,
    DateTime? selectedDob,
    bool clearSelectedDob = false,
    DateTime? editDob,
    String? selectedGender,
    String? editGender,
    String? bloodGroup,
  }) {
    return ParentChildrenState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      children: children ?? this.children,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      selectedDob: clearSelectedDob ? null : selectedDob ?? this.selectedDob,
      editDob: editDob ?? this.editDob,
      selectedGender: selectedGender ?? this.selectedGender,
      editGender: editGender ?? this.editGender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class ParentChildrenController extends StateNotifier<ParentChildrenState> {
  ParentChildrenController() : super(const ParentChildrenState()) {
    loadChildren();
  }

  final _client = Supabase.instance.client;

  // ── Form keys ─────────────────────────────────────────────────────
  final addFormKey = GlobalKey<FormState>();

  // ── Add child controllers ─────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final allergyCtrl = TextEditingController();
  final medCtrl = TextEditingController();

  // ── Edit child controllers ────────────────────────────────────────
  final editNameCtrl = TextEditingController();
  final editAllergyCtrl = TextEditingController();
  final editMedCtrl = TextEditingController();
  final editAddressCtrl = TextEditingController();

  static const genderOptions = ['Male', 'Female', 'Other'];
  static const bloodGroupOptions = [
    '',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  String _normaliseGender(String? raw) {
    if (raw == null || raw.isEmpty) return 'Male';
    final titleCase =
        '${raw[0].toUpperCase()}${raw.substring(1).toLowerCase()}';
    return genderOptions.contains(titleCase) ? titleCase : 'Male';
  }

  // ── Load ──────────────────────────────────────────────────────────
  Future<void> loadChildren() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) {
        state = state.copyWith(isLoading: false, children: []);
        return;
      }
      final data = await _client
          .from('children')
          .select(
            'id, full_name, date_of_birth, gender, allergies, '
            'status, classrooms(name)',
          )
          .eq('parent_id', uid)
          .order('full_name');
      state = state.copyWith(isLoading: false, children: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── Add child ─────────────────────────────────────────────────────
  void setSelectedDob(DateTime dob) => state = state.copyWith(selectedDob: dob);

  void setSelectedGender(String gender) =>
      state = state.copyWith(selectedGender: gender);

  Future<void> pickAddDob(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2021),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) setSelectedDob(picked);
  }

  Future<bool> addChild(BuildContext context) async {
    if (!addFormKey.currentState!.validate()) return false;
    if (state.selectedDob == null) return false;

    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;

    state = state.copyWith(isSaving: true);
    try {
      await _client.from('children').insert({
        'full_name': nameCtrl.text.trim(),
        'date_of_birth': state.selectedDob!.toIso8601String().substring(0, 10),
        'gender': state.selectedGender,
        'allergies': allergyCtrl.text.trim().isEmpty
            ? null
            : allergyCtrl.text.trim(),
        'medical_notes': medCtrl.text.trim().isEmpty
            ? null
            : medCtrl.text.trim(),
        'parent_id': uid,
        'status': 'active',
      });

      _clearAddForm();
      await loadChildren();
      return true;
    } on PostgrestException {
      state = state.copyWith(isSaving: false);
      return false;
    } catch (_) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  void _clearAddForm() {
    nameCtrl.clear();
    allergyCtrl.clear();
    medCtrl.clear();
    state = state.copyWith(
      isSaving: false,
      clearSelectedDob: true,
      selectedGender: 'Male',
    );
  }

  // ── Load child for edit ───────────────────────────────────────────
  Future<Map<String, dynamic>?> loadChildDetail(String childId) async {
    try {
      final data = await _client
          .from('children')
          .select(
            'full_name, date_of_birth, gender, allergies, '
            'medical_notes, blood_group, address, classrooms(name)',
          )
          .eq('id', childId)
          .single();

      editNameCtrl.text = data['full_name'] as String? ?? '';
      editAllergyCtrl.text = data['allergies'] as String? ?? '';
      editMedCtrl.text = data['medical_notes'] as String? ?? '';
      editAddressCtrl.text = data['address'] as String? ?? '';

      final dobStr = data['date_of_birth'] as String?;
      DateTime parsedDob = DateTime(2021, 1, 1);
      if (dobStr != null && dobStr.isNotEmpty) {
        try {
          parsedDob = DateTime.parse(dobStr);
        } catch (_) {}
      }

      final rawBg = data['blood_group'] as String? ?? '';
      final bg = bloodGroupOptions.contains(rawBg) ? rawBg : '';

      state = state.copyWith(
        editDob: parsedDob,
        editGender: _normaliseGender(data['gender'] as String?),
        bloodGroup: bg,
      );

      return data;
    } catch (_) {
      return null;
    }
  }

  void setEditDob(DateTime dob) => state = state.copyWith(editDob: dob);

  void setEditGender(String gender) =>
      state = state.copyWith(editGender: gender);

  void setBloodGroup(String bg) => state = state.copyWith(bloodGroup: bg);

  Future<void> pickEditDob(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.editDob ?? DateTime(2021),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) setEditDob(picked);
  }

  Future<bool> saveChildChanges(String childId) async {
    state = state.copyWith(isSaving: true);
    try {
      await _client
          .from('children')
          .update({
            'full_name': editNameCtrl.text.trim(),
            'date_of_birth': state.editDob!.toIso8601String().substring(0, 10),
            'gender': state.editGender.toLowerCase(),
            'allergies': editAllergyCtrl.text.trim().isEmpty
                ? null
                : editAllergyCtrl.text.trim(),
            'medical_notes': editMedCtrl.text.trim().isEmpty
                ? null
                : editMedCtrl.text.trim(),
            'blood_group': state.bloodGroup.isEmpty ? null : state.bloodGroup,
            'address': editAddressCtrl.text.trim().isEmpty
                ? null
                : editAddressCtrl.text.trim(),
          })
          .eq('id', childId);
      state = state.copyWith(isSaving: false);
      return true;
    } on PostgrestException {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    allergyCtrl.dispose();
    medCtrl.dispose();
    editNameCtrl.dispose();
    editAllergyCtrl.dispose();
    editMedCtrl.dispose();
    editAddressCtrl.dispose();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final parentChildrenProvider =
    StateNotifierProvider<ParentChildrenController, ParentChildrenState>(
      (ref) => ParentChildrenController(),
    );

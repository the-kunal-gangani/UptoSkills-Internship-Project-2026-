enum FormType { activity, nutrition, growth, incident }

class HistoryEntry {
  final FormType type;
  final Map<String, dynamic> data;

  const HistoryEntry({required this.type, required this.data});

  DateTime get createdAt =>
      DateTime.tryParse(data['created_at'] ?? '') ?? DateTime(0);
}

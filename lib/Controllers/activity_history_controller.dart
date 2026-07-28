import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/history_entry_model.dart';

final activityHistoryProvider =
    StreamProvider.family<List<HistoryEntry>, String>((ref, childId) {
  final supabase = Supabase.instance.client;

  final controller = StreamController<List<HistoryEntry>>();

  List<Map<String, dynamic>> activities = [];
  List<Map<String, dynamic>> nutrition = [];
  List<Map<String, dynamic>> growth = [];
  List<Map<String, dynamic>> incidents = [];

  void updateEntries() {
    final entries = <HistoryEntry>[];
    for (final row in activities) {
      entries.add(HistoryEntry(type: FormType.activity, data: row));
    }
    for (final row in nutrition) {
      entries.add(HistoryEntry(type: FormType.nutrition, data: row));
    }
    for (final row in growth) {
      entries.add(HistoryEntry(type: FormType.growth, data: row));
    }
    for (final row in incidents) {
      entries.add(HistoryEntry(type: FormType.incident, data: row));
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (!controller.isClosed) {
      controller.add(entries);
    }
  }

  final sub1 = supabase
      .from('activities')
      .stream(primaryKey: ['id'])
      .eq('child_id', childId)
      .listen((data) {
        activities = data;
        updateEntries();
      });

  final sub2 = supabase
      .from('nutrition_records')
      .stream(primaryKey: ['id'])
      .eq('child_id', childId)
      .listen((data) {
        nutrition = data;
        updateEntries();
      });

  final sub3 = supabase
      .from('growth_records')
      .stream(primaryKey: ['id'])
      .eq('child_id', childId)
      .listen((data) {
        growth = data;
        updateEntries();
      });

  final sub4 = supabase
      .from('incidents')
      .stream(primaryKey: ['id'])
      .eq('child_id', childId)
      .listen((data) {
        incidents = data;
        updateEntries();
      });

  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
    sub3.cancel();
    sub4.cancel();
    controller.close();
  });

  return controller.stream;
});
final activityFilterProvider = StateProvider<FormType?>((ref) => null);

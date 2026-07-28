import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiInsightsState {
  final Map<String, dynamic>? nutrition;
  final Map<String, dynamic>? sleep;
  final Map<String, dynamic>? hydration;
  final Map<String, dynamic>? medical;
  final Map<String, dynamic>? growth;
  final bool isLoading;
  final String? error;

  AiInsightsState({
    this.nutrition,
    this.sleep,
    this.hydration,
    this.medical,
    this.growth,
    this.isLoading = false,
    this.error,
  });

  AiInsightsState copyWith({
    Map<String, dynamic>? nutrition,
    Map<String, dynamic>? sleep,
    Map<String, dynamic>? hydration,
    Map<String, dynamic>? medical,
    Map<String, dynamic>? growth,
    bool? isLoading,
    String? error,
  }) {
    return AiInsightsState(
      nutrition: nutrition ?? this.nutrition,
      sleep: sleep ?? this.sleep,
      hydration: hydration ?? this.hydration,
      medical: medical ?? this.medical,
      growth: growth ?? this.growth,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AiInsightsController extends StateNotifier<AiInsightsState> {
  final String childId;
  AiInsightsController(this.childId) : super(AiInsightsState()) {
    loadInsights();
  }

  final _db = Supabase.instance.client;

  Future<void> loadInsights({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      if (!forceRefresh) {
        // 1. Check local DB cache first
        final cache = await _db
            .from('child_ai_insights')
            .select('*')
            .eq('child_id', childId)
            .eq('date', todayStr)
            .maybeSingle();

        if (cache != null) {
          state = state.copyWith(
            nutrition: cache['nutrition'] as Map<String, dynamic>?,
            sleep: cache['sleep'] as Map<String, dynamic>?,
            hydration: cache['hydration'] as Map<String, dynamic>?,
            medical: cache['medical'] as Map<String, dynamic>?,
            growth: cache['growth'] as Map<String, dynamic>?,
            isLoading: false,
          );
          return;
        }
      }

      // 2. Cache doesn't exist or forced, invoke Edge Function
      final response = await _db.functions.invoke(
        'generate-child-insights',
        body: {'child_id': childId},
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Edge Function error');
      }

      final data = response.data as Map<String, dynamic>;
      state = state.copyWith(
        nutrition: data['nutrition'] as Map<String, dynamic>?,
        sleep: data['sleep'] as Map<String, dynamic>?,
        hydration: data['hydration'] as Map<String, dynamic>?,
        medical: data['medical'] as Map<String, dynamic>?,
        growth: data['growth'] as Map<String, dynamic>?,
        isLoading: false,
      );

    } catch (e) {
      debugPrint('[AI Insights] Error loading insights: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load insights. Ensure child records are active. Details: $e',
      );
    }
  }
}

final aiInsightsProvider =
    StateNotifierProvider.family<AiInsightsController, AiInsightsState, String>(
  (ref, childId) => AiInsightsController(childId),
);

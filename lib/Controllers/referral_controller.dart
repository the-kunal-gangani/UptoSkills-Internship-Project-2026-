import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/models/referral_code_model.dart';

class ReferralState {
  final bool isLoading;
  final List<ReferralCodeModel> codes;
  final String? errorMessage;

  const ReferralState({
    this.isLoading = false,
    this.codes = const [],
    this.errorMessage,
  });

  ReferralState copyWith({
    bool? isLoading,
    List<ReferralCodeModel>? codes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReferralState(
      isLoading: isLoading ?? this.isLoading,
      codes: codes ?? this.codes,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ReferralController extends StateNotifier<ReferralState> {
  ReferralController() : super(const ReferralState()) {
    loadCodes();
  }

  final _client = Supabase.instance.client;

  Future<void> loadCodes() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _client
          .from('referral_codes')
          .select()
          .order('created_at', ascending: false);

      final codes = (data as List)
          .map(
            (item) =>
                ReferralCodeModel.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList();

      state = state.copyWith(isLoading: false, codes: codes);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> generateCode({
    required String role,
    required DateTime expiresAt,
  }) async {
    try {
      final code = await _buildUniqueCode();
      await _client.from('referral_codes').insert({
        'code': code,
        'role': role,
        'is_used': false,
        'is_active': true,
        'expires_at': expiresAt.toUtc().toIso8601String(),
        'created_by': _client.auth.currentUser?.id,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      await loadCodes();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> disableCode(String id) async {
    try {
      await _client
          .from('referral_codes')
          .update({'is_active': false})
          .eq('id', id);
      await loadCodes();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteCode(String id) async {
    try {
      await _client.from('referral_codes').delete().eq('id', id);
      await loadCodes();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<String> _buildUniqueCode() async {
    const maxAttempts = 10;
    final random = Random();

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final code =
          'TINY${_randomChar(random)}${random.nextInt(10)}${_randomChar(random)}${random.nextInt(10)}';
      final existing = await _client
          .from('referral_codes')
          .select('id')
          .eq('code', code)
          .maybeSingle();

      if (existing == null) {
        return code;
      }
    }

    throw Exception('Unable to generate a unique referral code.');
  }

  String _randomChar(Random random) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return chars[random.nextInt(chars.length)];
  }
}

final referralControllerProvider =
    StateNotifierProvider<ReferralController, ReferralState>(
      (ref) => ReferralController(),
    );

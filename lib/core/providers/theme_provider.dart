import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the current theme mode (light, dark, or system)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

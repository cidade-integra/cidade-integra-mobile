import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateLimiter {
  RateLimiter._();

  /// Returns true if the action is allowed, false if rate-limited.
  /// Stores timestamps in SharedPreferences keyed by [actionKey].
  static Future<bool> canPerform(
    String actionKey, {
    int maxPerHour = 5,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'rate_$actionKey';
    final stored = prefs.getStringList(key) ?? [];
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 1));

    final recent = stored
        .map((s) => DateTime.tryParse(s))
        .where((t) => t != null && t.isAfter(cutoff))
        .cast<DateTime>()
        .toList();

    if (recent.length >= maxPerHour) {
      debugPrint('[RateLimiter] Blocked: $actionKey (${recent.length}/$maxPerHour in last hour)');
      return false;
    }

    recent.add(now);
    await prefs.setStringList(
      key,
      recent.map((t) => t.toIso8601String()).toList(),
    );
    return true;
  }

  /// Clears stored timestamps for a given action.
  static Future<void> reset(String actionKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rate_$actionKey');
  }
}

/// Debouncer that delays execution until input stops for [duration].
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 400)});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

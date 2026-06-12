import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiskEntry {
  final String type; // 'Diabetes', 'Heart', 'Kidney', 'Thyroid'
  final double riskPercentage;
  final int predictedClass;
  final DateTime timestamp;

  RiskEntry({
    required this.type,
    required this.riskPercentage,
    required this.predictedClass,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'riskPercentage': riskPercentage,
    'predictedClass': predictedClass,
    'timestamp': timestamp.toIso8601String(),
  };

  factory RiskEntry.fromJson(Map<String, dynamic> json) => RiskEntry(
    type: json['type'] ?? '',
    riskPercentage: (json['riskPercentage'] ?? 0.0).toDouble(),
    predictedClass: json['predictedClass'] ?? 0,
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
  );
}

class HealthHistoryService extends ChangeNotifier {
  static const _key = 'health_history';
  List<RiskEntry> _entries = [];

  List<RiskEntry> get entries => List.unmodifiable(_entries);

  /// Most recent entry for each type
  Map<String, RiskEntry> get latestByType {
    final map = <String, RiskEntry>{};
    for (final e in _entries.reversed) {
      map.putIfAbsent(e.type, () => e);
    }
    return map;
  }

  HealthHistoryService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _entries = list.map((e) => RiskEntry.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> addEntry(RiskEntry entry) async {
    _entries.add(entry);
    // Keep only last 50
    if (_entries.length > 50) {
      _entries = _entries.sublist(_entries.length - 50);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_entries.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _entries.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }

  String riskLabel(double pct) {
    if (pct > 50) return 'High';
    if (pct > 20) return 'Moderate';
    return 'Low';
  }

  Color riskColor(double pct) {
    if (pct > 50) return Colors.red;
    if (pct > 20) return Colors.orange;
    return Colors.green;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/milk_type_adapter.dart';

part 'providers.g.dart';

// Theme Provider
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final settingsBox = Hive.box('settings');
    final isDark = settingsBox.get('isDarkMode', defaultValue: false);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final settingsBox = Hive.box('settings');
    settingsBox.put('isDarkMode', newMode == ThemeMode.dark);
    state = newMode;
  }
}

// Settings Provider
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Map<String, dynamic> build() {
    final settingsBox = Hive.box('settings');
    return {
      'cowMilkRate': settingsBox.get('cowMilkRate', defaultValue: 0.0),
      'buffaloMilkRate': settingsBox.get('buffaloMilkRate', defaultValue: 0.0),
    };
  }

  void updateCowRate(double rate) {
    final settingsBox = Hive.box('settings');
    settingsBox.put('cowMilkRate', rate);
    state = {...state, 'cowMilkRate': rate};
  }

  void updateBuffaloRate(double rate) {
    final settingsBox = Hive.box('settings');
    settingsBox.put('buffaloMilkRate', rate);
    state = {...state, 'buffaloMilkRate': rate};
  }
}

// Records Provider
@riverpod
class RecordsNotifier extends _$RecordsNotifier {
  @override
  List<MilkRecord> build() {
    final box = Hive.box<MilkRecord>('records');
    // Return a copy of the values so Riverpod detects changes
    return List.from(box.values);
  }

  void addRecord(MilkRecord record) {
    print(
        '🔥 RecordsNotifier: Adding record - ${record.quantity}L ${record.type}');
    final box = Hive.box<MilkRecord>('records');
    box.add(record);
    // Update state with new list to trigger rebuilds
    state = List.from(box.values);
  }

  void deleteRecord(int key) {
    final box = Hive.box<MilkRecord>('records');
    box.delete(key);
    // Update state with new list to trigger rebuilds
    state = List.from(box.values);
  }
}

// Computed providers for insights
@riverpod
double totalQuantity(TotalQuantityRef ref) {
  final records = ref.watch(recordsNotifierProvider);
  final total = records.fold(0.0, (sum, record) => sum + record.quantity);
  print('📊 totalQuantity computed: $total L');
  return total;
}

@riverpod
double totalEarnings(TotalEarningsRef ref) {
  final records = ref.watch(recordsNotifierProvider);
  final settings = ref.watch(settingsNotifierProvider);
  final total = records.fold(0.0, (sum, record) {
    final rate = record.type == MilkType.cow
        ? settings['cowMilkRate']
        : settings['buffaloMilkRate'];
    return sum + (record.quantity * rate);
  });
  print('💰 totalEarnings computed: ₹$total');
  return total;
}

@riverpod
int recentRecordsCount(RecentRecordsCountRef ref) {
  final records = ref.watch(recordsNotifierProvider);
  final weekAgo = DateTime.now().subtract(const Duration(days: 7));
  final count = records.where((record) => record.date.isAfter(weekAgo)).length;
  print('📅 recentRecordsCount computed: $count');
  return count;
}

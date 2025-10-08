import 'package:flutter/foundation.dart';
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
      'weekStartDay': settingsBox.get('weekStartDay',
          defaultValue: 1), // 1 = Monday, 7 = Sunday
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

  void updateWeekStartDay(int day) {
    final settingsBox = Hive.box('settings');
    settingsBox.put('weekStartDay', day);
    state = {...state, 'weekStartDay': day};
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
    if (kDebugMode) {
      print(
          '🔥 RecordsNotifier: Adding record - ${record.quantity}L ${record.type}');
    }
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
double totalQuantity(Ref ref) {
  final records = ref.watch(recordsNotifierProvider);
  final total = records.fold(0.0, (sum, record) => sum + record.quantity);
  if (kDebugMode) {
    print('📊 totalQuantity computed: $total L');
  }
  return total;
}

@riverpod
double totalEarnings(Ref ref) {
  final records = ref.watch(recordsNotifierProvider);
  final settings = ref.watch(settingsNotifierProvider);
  final total = records.fold(0.0, (sum, record) {
    final rate = record.type == MilkType.cow
        ? settings['cowMilkRate']
        : settings['buffaloMilkRate'];
    return sum + (record.quantity * rate);
  });
  if (kDebugMode) {
    print('💰 totalEarnings computed: ₹$total');
  }
  return total;
}

@riverpod
int recentRecordsCount(Ref ref) {
  final records = ref.watch(recordsNotifierProvider);
  final weekAgo = DateTime.now().subtract(const Duration(days: 7));
  final count = records.where((record) => record.date.isAfter(weekAgo)).length;
  if (kDebugMode) {
    print('📅 recentRecordsCount computed: $count');
  }
  return count;
}

@riverpod
double thisWeekQuantity(Ref ref) {
  final records = ref.watch(recordsNotifierProvider);
  final settings = ref.watch(settingsNotifierProvider);
  final weekStartDay = settings['weekStartDay'] as int;

  final now = DateTime.now();
  // Find the start of the current week based on weekStartDay
  final daysSinceWeekStart = (now.weekday - weekStartDay) % 7;
  final weekStart = now.subtract(Duration(days: daysSinceWeekStart));
  final weekStartDate =
      DateTime(weekStart.year, weekStart.month, weekStart.day);

  final thisWeekRecords = records.where((record) =>
      record.date.isAfter(weekStartDate.subtract(const Duration(days: 1))) &&
      record.date.isBefore(weekStartDate.add(const Duration(days: 7))));

  final total =
      thisWeekRecords.fold(0.0, (sum, record) => sum + record.quantity);
  if (kDebugMode) {
    print(
        '📅 thisWeekQuantity computed: $total L (week starts on day $weekStartDay)');
  }
  return total;
}

@riverpod
double todayQuantity(Ref ref) {
  final records = ref.watch(recordsNotifierProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final todayRecords = records.where((record) =>
      record.date.isAfter(today.subtract(const Duration(days: 1))) &&
      record.date.isBefore(today.add(const Duration(days: 1))));

  final total = todayRecords.fold(0.0, (sum, record) => sum + record.quantity);
  if (kDebugMode) {
    print('📅 todayQuantity computed: $total L');
  }
  return total;
}

@riverpod
double todayEarnings(Ref ref) {
  final records = ref.watch(recordsNotifierProvider);
  final settings = ref.watch(settingsNotifierProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final todayRecords = records.where((record) =>
      record.date.isAfter(today.subtract(const Duration(days: 1))) &&
      record.date.isBefore(today.add(const Duration(days: 1))));

  final total = todayRecords.fold(0.0, (sum, record) {
    final rate = record.type == MilkType.cow
        ? settings['cowMilkRate']
        : settings['buffaloMilkRate'];
    return sum + (record.quantity * rate);
  });
  if (kDebugMode) {
    print('💰 todayEarnings computed: ₹$total');
  }
  return total;
}

@riverpod
double thisWeekEarnings(Ref ref) {
  final records = ref.watch(recordsNotifierProvider);
  final settings = ref.watch(settingsNotifierProvider);
  final weekStartDay = settings['weekStartDay'] as int;

  final now = DateTime.now();
  // Find the start of the current week based on weekStartDay
  final daysSinceWeekStart = (now.weekday - weekStartDay) % 7;
  final weekStart = now.subtract(Duration(days: daysSinceWeekStart));
  final weekStartDate =
      DateTime(weekStart.year, weekStart.month, weekStart.day);

  final thisWeekRecords = records.where((record) =>
      record.date.isAfter(weekStartDate.subtract(const Duration(days: 1))) &&
      record.date.isBefore(weekStartDate.add(const Duration(days: 7))));

  final total = thisWeekRecords.fold(0.0, (sum, record) {
    final rate = record.type == MilkType.cow
        ? settings['cowMilkRate']
        : settings['buffaloMilkRate'];
    return sum + (record.quantity * rate);
  });
  if (kDebugMode) {
    print(
        '💰 thisWeekEarnings computed: ₹$total (week starts on day $weekStartDay)');
  }
  return total;
}

@riverpod
double thisMonthQuantity(Ref ref) {
  final records = ref.watch(recordsNotifierProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);

  final thisMonthRecords = records.where((record) =>
      record.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
      record.date.isBefore(monthStart.add(const Duration(days: 32))));

  final total =
      thisMonthRecords.fold(0.0, (sum, record) => sum + record.quantity);
  if (kDebugMode) {
    print('📅 thisMonthQuantity computed: $total L');
  }
  return total;
}

@riverpod
double thisMonthEarnings(Ref ref) {
  final records = ref.watch(recordsNotifierProvider);
  final settings = ref.watch(settingsNotifierProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);

  final thisMonthRecords = records.where((record) =>
      record.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
      record.date.isBefore(monthStart.add(const Duration(days: 32))));

  final total = thisMonthRecords.fold(0.0, (sum, record) {
    final rate = record.type == MilkType.cow
        ? settings['cowMilkRate']
        : settings['buffaloMilkRate'];
    return sum + (record.quantity * rate);
  });
  if (kDebugMode) {
    print('💰 thisMonthEarnings computed: ₹$total');
  }
  return total;
}

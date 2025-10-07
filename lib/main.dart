import 'package:dairykhata/pages/main_navigation.dart';
import 'package:dairykhata/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/milk_type_adapter.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MilkRecordAdapter());
  Hive.registerAdapter(MilkTypeAdapter());
  await Hive.openBox('settings');
  await Hive.openBox<MilkRecord>('records');
  runApp(const ProviderScope(child: DairyBookApp()));
}

class DairyBookApp extends ConsumerWidget {
  const DairyBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dairy Book',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainNavigation(),
    );
  }
}

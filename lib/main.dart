
import 'package:dairykhata/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/milk_type_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MilkRecordAdapter());
  Hive.registerAdapter(MilkTypeAdapter());
  await Hive.openBox('settings');
  await Hive.openBox<MilkRecord>('records');
  runApp(const DairyBookApp());
}

class DairyBookApp extends StatelessWidget {
  const DairyBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dairy Book',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Outfit',),
      home: const HomePage(),
    );
  }
}
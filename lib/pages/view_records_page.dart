import 'dart:collection';

import 'package:dairykhata/models/milk_type_adapter.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ViewRecordsPage extends StatelessWidget {
  const ViewRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Records')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<MilkRecord>('records').listenable(),
        builder: (context, Box<MilkRecord> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No records found'));
          }
          final groupedRecords = _groupRecordsByDate(box.values.toList());
          return ListView.builder(
            itemCount: groupedRecords.length,
            itemBuilder: (context, index) {
              final date = groupedRecords.keys.elementAt(index);
              final records = groupedRecords[date]!;
              return ExpansionTile(
                title: Text(DateFormat('yyyy-MM-dd').format(date)),
                children: records.map((record) {
                  return ListTile(
                    title: Text(record.type == MilkType.cow ? 'Cow' : 'Buffalo'),
                    subtitle: Text('Quantity: ${record.quantity} liters'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        box.delete(record.key);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Record deleted')),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

//   Map<DateTime, List<MilkRecord>> _groupRecordsByDate(List<MilkRecord> records) {
//     final Map<DateTime, List<MilkRecord>> groupedRecords = {};
//     for (var record in records) {
//       final date = DateTime(record.date.year, record.date.month, record.date.day);
//       if (groupedRecords.containsKey(date)) {
//         groupedRecords[date]!.add(record);
//       } else {
//         groupedRecords[date] = [record];
//       }
//     }
//     return groupedRecords;
//   }
// }


  Map<DateTime, List<MilkRecord>> _groupRecordsByDate(List<MilkRecord> records) {
    final Map<DateTime, List<MilkRecord>> groupedRecords = {};

    // Group records by date
    for (var record in records) {
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      if (groupedRecords.containsKey(date)) {
        groupedRecords[date]!.add(record);
      } else {
        groupedRecords[date] = [record];
      }
    }

    // Sort dates in descending order (recent dates first)
    final sortedRecords = SplayTreeMap<DateTime, List<MilkRecord>>.from(
      groupedRecords,
          (a, b) => b.compareTo(a),  // Compare in reverse order
    );

    return sortedRecords;
  }}
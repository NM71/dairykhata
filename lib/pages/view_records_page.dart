import 'dart:collection';

import 'package:dairykhata/models/milk_type_adapter.dart';
import 'package:dairykhata/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ViewRecordsPage extends StatelessWidget {
  const ViewRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, isSmallScreen ? 60 : 70),
        child: AppBar(
          backgroundColor: const Color(0xff0e2a62).withValues(alpha: 0.8),
          elevation: 0,
          title: Text(
            'Milk Records',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: isSmallScreen ? 24 : 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: padding,
              right: padding,
              top: padding,
              bottom: padding + 86),
          child: ValueListenableBuilder(
            valueListenable: Hive.box<MilkRecord>('records').listenable(),
            builder: (context, Box<MilkRecord> box, _) {
              if (box.values.isEmpty) {
                return _buildEmptyState(context, isSmallScreen);
              }
              final groupedRecords = _groupRecordsByDate(box.values.toList());
              return ListView.builder(
                itemCount: groupedRecords.length,
                itemBuilder: (context, index) {
                  final date = groupedRecords.keys.elementAt(index);
                  final records = groupedRecords[date]!;
                  return _buildDateCard(context, date, records, isSmallScreen);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt_outlined,
            size: isSmallScreen ? 80 : 100,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'No Records Yet',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Add some milk records to see them here',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(BuildContext context, DateTime date,
      List<MilkRecord> records, bool isSmallScreen) {
    final totalQuantity =
        records.fold<double>(0, (sum, record) => sum + record.quantity);

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: const Color(0xff0e2a62),
              size: isSmallScreen ? 20 : 24,
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM dd').format(date),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    '${records.length} record${records.length > 1 ? 's' : ''} • ${totalQuantity.toStringAsFixed(1)} L total',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: records.map((record) {
          return _buildRecordTile(context, record, isSmallScreen);
        }).toList(),
      ),
    );
  }

  Widget _buildRecordTile(
      BuildContext context, MilkRecord record, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: 4,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]?.withValues(alpha: 0.3)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: record.type == MilkType.cow
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.brown.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              record.type == MilkType.cow ? Icons.pets : Icons.pets,
              color: record.type == MilkType.cow ? Colors.blue : Colors.brown,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.type == MilkType.cow ? 'Cow Milk' : 'Buffalo Milk',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${record.quantity} liters',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red[400],
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Record'),
                  content: const Text(
                      'Are you sure you want to delete this record?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Hive.box<MilkRecord>('records').delete(record.key);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Record deleted')),
                        );
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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

  Map<DateTime, List<MilkRecord>> _groupRecordsByDate(
      List<MilkRecord> records) {
    final Map<DateTime, List<MilkRecord>> groupedRecords = {};

    // Group records by date
    for (var record in records) {
      final date =
          DateTime(record.date.year, record.date.month, record.date.day);
      if (groupedRecords.containsKey(date)) {
        groupedRecords[date]!.add(record);
      } else {
        groupedRecords[date] = [record];
      }
    }

    // Sort dates in descending order (recent dates first)
    final sortedRecords = SplayTreeMap<DateTime, List<MilkRecord>>.from(
      groupedRecords,
      (a, b) => b.compareTo(a), // Compare in reverse order
    );

    return sortedRecords;
  }
}

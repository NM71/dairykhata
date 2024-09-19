import 'package:dairykhata/models/milk_type_adapter.dart';
import 'package:dairykhata/pages/add_record_page.dart';
import 'package:dairykhata/pages/view_records_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _settingsBox = Hive.box('settings');

  double _cowMilkRate = 0.0;
  double _buffaloMilkRate = 0.0;

  @override
  void initState() {
    super.initState();
    _cowMilkRate = _settingsBox.get('cowMilkRate', defaultValue: 0.0);
    _buffaloMilkRate = _settingsBox.get('buffaloMilkRate', defaultValue: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/dairybook.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 70),
          child: AppBar(
            backgroundColor: const Color(0xff0e2a62),
            elevation: 0,
            title: const Text(
              'DairyBook',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () => _navigateTo(context, const AddRecordPage()),
                child: const Text(
                  'Add Record',
                  style: TextStyle(color: Color(0xff113370), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () => _navigateTo(context, const ViewRecordsPage()),
                child: const Text(
                  'View Records',
                  style: TextStyle(color: Color(0xff113370), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: _showSetRatesDialog,
                child: const Text(
                  'Set Milk Rates',
                  style: TextStyle(color: Color(0xff113370), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () => _generateReceipt(context),
                child: const Text(
                  'Generate Receipt',
                  style: TextStyle(color: Color(0xff113370), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _showSetRatesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Milk Rates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Cow Milk Rate'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _cowMilkRate = double.tryParse(value) ?? 0.0,
              controller: TextEditingController(text: _cowMilkRate.toString()),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Buffalo Milk Rate'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _buffaloMilkRate = double.tryParse(value) ?? 0.0,
              controller:
                  TextEditingController(text: _buffaloMilkRate.toString()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _settingsBox.put('cowMilkRate', _cowMilkRate);
              _settingsBox.put('buffaloMilkRate', _buffaloMilkRate);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _generateReceipt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
            child: Text(
          'Generate Receipt',
          style: TextStyle(color: Color(0xff113370)),
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _generateAndPrintReceipt(7),
                child: const Text(
                  'Last 7 days',
                  style: TextStyle(color: Color(0xff113370)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _generateAndPrintReceipt(30),
                child: const Text(
                  'Last 30 days',
                  style: TextStyle(color: Color(0xff113370)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _showCustomDateRangeDialog(context),
                child: const Text(
                  'Custom Date Range',
                  style: TextStyle(color: Color(0xff113370)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDateRangeDialog(BuildContext context) {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
    DateTime endDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Select Date Range',
          style: TextStyle(color: Color(0xff113370)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDateRange:
                      DateTimeRange(start: startDate, end: endDate),
                );
                if (picked != null) {
                  startDate = picked.start;
                  endDate = picked.end;
                }
              },
              child: const Text(
                'Select Dates',
                style: TextStyle(color: Color(0xff113370)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _generateAndPrintReceipt(null,
                    startDate: startDate, endDate: endDate);
              },
              child: const Text(
                'Generate Receipt',
                style: TextStyle(color: Color(0xff113370)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _generateAndPrintReceipt(int? days,
  //     {DateTime? startDate, DateTime? endDate}) async {
  //   final recordsBox = Hive.box<MilkRecord>('records');
  //   final now = DateTime.now();
  //   startDate ??= now.subtract(Duration(days: days ?? 7));
  //   endDate ??= now;
  //
  //   final records = recordsBox.values
  //       .where((record) =>
  //   record.date.isAfter(startDate!.subtract(Duration(days: 1))) &&
  //       record.date.isBefore(endDate!.add(Duration(days: 1))))
  //       .toList();
  //
  //   records.sort((a, b) => a.date.compareTo(b.date));
  //
  //   final pdf = pw.Document();
  //
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //           children: [
  //             pw.Text('Dairy Book Receipt',
  //                 style: pw.TextStyle(
  //                     fontSize: 20, fontWeight: pw.FontWeight.bold,)),
  //             pw.SizedBox(height: 20),
  //             pw.Text('From: ${DateFormat('yyyy-MM-dd').format(startDate!)}'),
  //             pw.Text('To: ${DateFormat('yyyy-MM-dd').format(endDate!)}'),
  //             pw.SizedBox(height: 20),
  //             pw.TableHelper.fromTextArray(
  //               headers: ['Date', 'Type', 'Quantity', 'Rate', 'Amount'],
  //               data: records.map((record) {
  //                 final rate = record.type == MilkType.cow
  //                     ? _cowMilkRate
  //                     : _buffaloMilkRate;
  //                 final amount = record.quantity * rate;
  //                 return [
  //                   DateFormat('yyyy-MM-dd').format(record.date),
  //                   record.type == MilkType.cow ? 'Cow' : 'Buffalo',
  //                   record.quantity.toString(),
  //                   rate.toStringAsFixed(2),
  //                   amount.toStringAsFixed(2),
  //                 ];
  //               }).toList(),
  //             ),
  //             pw.SizedBox(height: 20),
  //             pw.Text(
  //                 'Total Amount: ${records.fold<double>(0, (sum, record) => sum + record.quantity * (record.type == MilkType.cow ? _cowMilkRate : _buffaloMilkRate)).toStringAsFixed(2)}'),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   await Printing.layoutPdf(
  //       onLayout: (PdfPageFormat format) async => pdf.save());
  // }

  void _generateAndPrintReceipt(int? days,
      {DateTime? startDate, DateTime? endDate}) async {
    final recordsBox = Hive.box<MilkRecord>('records');
    final now = DateTime.now();
    startDate ??= now.subtract(Duration(days: days ?? 7));
    endDate ??= now;

    final records = recordsBox.values
        .where((record) =>
            record.date.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            record.date.isBefore(endDate!.add(const Duration(days: 1))))
        .toList();

    records.sort((a, b) => a.date.compareTo(b.date));

    // Group records by date
    final groupedRecords = _groupRecordsByDate(records);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Dairy Book Receipt',
                  style: pw.TextStyle(
                    fontSize: 25,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.SizedBox(height: 20),
              pw.Text('From: ${DateFormat('yyyy-MM-dd').format(startDate!)}'),
              pw.Text('To: ${DateFormat('yyyy-MM-dd').format(endDate!)}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Date',
                  'Type',
                  'Total Quantity',
                  'Rate',
                  'Total Amount'
                ],
                data: groupedRecords.entries.expand((entry) {
                  final date = entry.key;
                  final recordsForDate = entry.value;

                  // Rows for the date (cow and buffalo milk separated)
                  List<List<String>> rows = [];

                  double cowTotalQuantity = 0;
                  double buffaloTotalQuantity = 0;
                  for (var record in recordsForDate) {
                    if (record.type == MilkType.cow) {
                      cowTotalQuantity += record.quantity;
                    } else if (record.type == MilkType.buffalo) {
                      buffaloTotalQuantity += record.quantity;
                    }
                  }

                  final cowTotalAmount = cowTotalQuantity * _cowMilkRate;
                  final buffaloTotalAmount =
                      buffaloTotalQuantity * _buffaloMilkRate;

                  // Add row for cow milk (if exists)
                  if (cowTotalQuantity > 0) {
                    rows.add([
                      DateFormat('yyyy-MM-dd')
                          .format(date), // Only show date for the first row
                      'Cow',
                      cowTotalQuantity.toStringAsFixed(2),
                      _cowMilkRate.toStringAsFixed(2),
                      cowTotalAmount.toStringAsFixed(2),
                    ]);
                  }

                  // Add row for buffalo milk (if exists), but leave date column empty
                  if (buffaloTotalQuantity > 0) {
                    rows.add([
                      '', // Leave date empty
                      'Buffalo',
                      buffaloTotalQuantity.toStringAsFixed(2),
                      _buffaloMilkRate.toStringAsFixed(2),
                      buffaloTotalAmount.toStringAsFixed(2),
                    ]);
                  }

                  return rows;
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Total Amount: ${records.fold<double>(0, (sum, record) => sum + record.quantity * (record.type == MilkType.cow ? _cowMilkRate : _buffaloMilkRate)).toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Map<DateTime, List<MilkRecord>> _groupRecordsByDate(
      List<MilkRecord> records) {
    final Map<DateTime, List<MilkRecord>> groupedRecords = {};
    for (var record in records) {
      final date =
          DateTime(record.date.year, record.date.month, record.date.day);
      if (groupedRecords.containsKey(date)) {
        groupedRecords[date]!.add(record);
      } else {
        groupedRecords[date] = [record];
      }
    }
    return groupedRecords;
  }
}

import 'package:dairykhata/models/milk_type_adapter.dart';
import 'package:dairykhata/providers/providers.dart';
import 'package:dairykhata/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

enum TimePeriod { allTime, thisWeek, thisMonth, today }

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  TimePeriod _selectedPeriod = TimePeriod.allTime;
  DateTime? _customMonthStartDate;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPeriodIndex = prefs.getInt('selectedPeriod') ?? 0;
    final savedMonthStartMillis = prefs.getInt('customMonthStartDate');

    setState(() {
      _selectedPeriod = TimePeriod.values[savedPeriodIndex];
      if (savedMonthStartMillis != null) {
        _customMonthStartDate =
            DateTime.fromMillisecondsSinceEpoch(savedMonthStartMillis);
      }
    });
  }

  Future<void> _saveSelectedPeriod(TimePeriod period) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedPeriod', period.index);
  }

  Future<void> _saveCustomMonthStartDate(DateTime? date) async {
    final prefs = await SharedPreferences.getInstance();
    if (date != null) {
      await prefs.setInt('customMonthStartDate', date.millisecondsSinceEpoch);
    } else {
      await prefs.remove('customMonthStartDate');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch all the providers
    final records = ref.watch(recordsNotifierProvider);
    final totalQuantity = ref.watch(totalQuantityProvider);
    final totalEarnings = ref.watch(totalEarningsProvider);
    final thisWeekQuantity = ref.watch(thisWeekQuantityProvider);
    final thisWeekEarnings = ref.watch(thisWeekEarningsProvider);
    final thisMonthQuantity = ref.watch(thisMonthQuantityProvider);
    final thisMonthEarnings = ref.watch(thisMonthEarningsProvider);
    final todayQuantity = ref.watch(todayQuantityProvider);
    final todayEarnings = ref.watch(todayEarningsProvider);

    // Get current values based on selected period
    double currentQuantity;
    double currentEarnings;

    switch (_selectedPeriod) {
      case TimePeriod.allTime:
        currentQuantity = totalQuantity;
        currentEarnings = totalEarnings;
        break;
      case TimePeriod.thisWeek:
        currentQuantity = thisWeekQuantity;
        currentEarnings = thisWeekEarnings;
        break;
      case TimePeriod.thisMonth:
        if (_customMonthStartDate != null) {
          // Calculate custom month period
          final startDate = DateTime(
              _customMonthStartDate!.year, _customMonthStartDate!.month, 1);
          final endDate = DateTime(
              _customMonthStartDate!.year, _customMonthStartDate!.month + 1, 1);

          final customMonthRecords = records.where((record) =>
              record.date
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              record.date.isBefore(endDate));

          currentQuantity = customMonthRecords.fold(
              0.0, (sum, record) => sum + record.quantity);

          final settings = ref.read(settingsNotifierProvider);
          currentEarnings = customMonthRecords.fold(0.0, (sum, record) {
            final rate = record.type == MilkType.cow
                ? settings['cowMilkRate']
                : settings['buffaloMilkRate'];
            return sum + (record.quantity * rate);
          });
        } else {
          // Use default current month
          currentQuantity = thisMonthQuantity;
          currentEarnings = thisMonthEarnings;
        }
        break;
      case TimePeriod.today:
        currentQuantity = todayQuantity;
        currentEarnings = todayEarnings;
        break;
    }

    print(
        '🏠 HomePage: Building with period=${_selectedPeriod.name}, quantity=$currentQuantity, earnings=$currentEarnings');

    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isSmallScreen ? 28.0 : 40.0;
    final buttonPadding = isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 32, vertical: 16);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, isSmallScreen ? 60 : 70),
        child: AppBar(
          backgroundColor: const Color(0xff0e2a62).withValues(alpha: 0.8),
          elevation: 0,
          title: Text(
            'DairyBook',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: titleFontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                left: padding,
                right: padding,
                top: padding,
                bottom: padding + 86),
            child: Column(
              children: [
                // Single Insights Card with dropdown and two sub-cards
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dropdown selector
                        Row(
                          children: [
                            const Icon(Icons.date_range,
                                color: Color(0xff0e2a62)),
                            const SizedBox(width: 8),
                            DropdownButton<TimePeriod>(
                              value: _selectedPeriod,
                              items: const [
                                DropdownMenuItem(
                                  value: TimePeriod.allTime,
                                  child: Text('All Time'),
                                ),
                                DropdownMenuItem(
                                  value: TimePeriod.thisWeek,
                                  child: Text('This Week'),
                                ),
                                DropdownMenuItem(
                                  value: TimePeriod.thisMonth,
                                  child: Text('This Month'),
                                ),
                                DropdownMenuItem(
                                  value: TimePeriod.today,
                                  child: Text('Today'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedPeriod = value;
                                    // Reset custom month start date when switching periods
                                    if (value != TimePeriod.thisMonth) {
                                      _customMonthStartDate = null;
                                      _saveCustomMonthStartDate(null);
                                    }
                                  });
                                  _saveSelectedPeriod(value);
                                }
                              },
                              underline: Container(),
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : const Color(0xff0e2a62),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Custom month start date selector
                        if (_selectedPeriod == TimePeriod.thisMonth) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(width: 32),
                              Text(
                                'Month Start: ${_customMonthStartDate != null ? DateFormat('MMM dd, yyyy').format(_customMonthStartDate!) : 'Current Month'}',
                                style: const TextStyle(
                                  color: Color(0xff0e2a62),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        _customMonthStartDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _customMonthStartDate = picked;
                                    });
                                    _saveCustomMonthStartDate(picked);
                                  }
                                },
                                icon: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Two cards in a row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSubCard(
                                'Total Milk',
                                '${currentQuantity.toStringAsFixed(1)} L',
                                Icons.local_drink,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSubCard(
                                'Total Earnings',
                                'Rs.${currentEarnings.toStringAsFixed(0)}',
                                Icons.attach_money,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 32 : 40),
                // Action Buttons
                Center(
                  child: SizedBox(
                    width: isSmallScreen ? double.infinity : 280,
                    child: ElevatedButton(
                      onPressed: () => _generateReceipt(context),
                      style: ElevatedButton.styleFrom(
                        padding: buttonPadding,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Text(
                            'Generate Receipt',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isCompact = false,
  }) {
    // Fixed height to ensure consistent card sizes
    final cardHeight = isCompact ? 120.0 : 140.0;
    final iconSize = isCompact ? 28.0 : 32.0;
    final valueFontSize = isCompact ? 18.0 : 20.0;
    final titleFontSize = isCompact ? 12.0 : 14.0;
    final padding = isCompact ? 12.0 : 16.0;

    return SizedBox(
      height: cardHeight,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: color),
              SizedBox(height: isCompact ? 6 : 8),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(height: isCompact ? 4 : 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
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

  void _generateReceipt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Generate Receipt')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => _generateAndPrintReceipt(7),
              child: const Text('Last 7 days'),
            ),
            TextButton(
              onPressed: () => _generateAndPrintReceipt(30),
              child: const Text('Last 30 days'),
            ),
            TextButton(
              onPressed: () => _showCustomDateRangeDialog(context),
              child: const Text('Custom Date Range'),
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
        title: const Text('Select Date Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
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
              child: const Text('Select Dates'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _generateAndPrintReceipt(null,
                    startDate: startDate, endDate: endDate);
              },
              child: const Text('Generate Receipt'),
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
    final settings = ref.read(settingsNotifierProvider);
    final cowRate = settings['cowMilkRate'] ?? 0.0;
    final buffaloRate = settings['buffaloMilkRate'] ?? 0.0;

    final now = DateTime.now();
    startDate ??= now.subtract(Duration(days: days ?? 7));
    endDate ??= now;

    final records = recordsBox.values
        .where((record) =>
            record.date.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            record.date.isBefore(endDate!.add(const Duration(days: 1))))
        .toList();

    records.sort((a, b) => a.date.compareTo(b.date));

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Dairy Book Receipt',
                  style: pw.TextStyle(
                      fontSize: 25, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('From: ${DateFormat('yyyy-MM-dd').format(startDate!)}'),
              pw.Text('To: ${DateFormat('yyyy-MM-dd').format(endDate!)}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Type', 'Quantity', 'Rate', 'Amount'],
                data: records.map((record) {
                  final rate =
                      record.type == MilkType.cow ? cowRate : buffaloRate;
                  final amount = record.quantity * rate;
                  return [
                    DateFormat('yyyy-MM-dd').format(record.date),
                    record.type == MilkType.cow ? 'Cow' : 'Buffalo',
                    record.quantity.toString(),
                    rate.toStringAsFixed(2),
                    amount.toStringAsFixed(2),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Total Amount: Rs ${records.fold<double>(0, (sum, record) => sum + record.quantity * (record.type == MilkType.cow ? cowRate : buffaloRate)).toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  double _calculateAverageDaily(double totalQuantity, List<MilkRecord> records,
      TimePeriod period, DateTime? customMonthStartDate) {
    if (totalQuantity == 0) return 0.0;

    int daysCount;

    switch (period) {
      case TimePeriod.allTime:
        // Count unique days with records
        final uniqueDays = records
            .map((record) =>
                DateTime(record.date.year, record.date.month, record.date.day))
            .toSet()
            .length;
        daysCount = uniqueDays > 0 ? uniqueDays : 1;
        break;

      case TimePeriod.thisWeek:
        // Use 7 days for this week
        daysCount = 7;
        break;

      case TimePeriod.thisMonth:
        if (customMonthStartDate != null) {
          // For custom month, count actual days with records in that period
          final startDate = DateTime(
              customMonthStartDate.year, customMonthStartDate.month, 1);
          final endDate = DateTime(
              customMonthStartDate.year, customMonthStartDate.month + 1, 1);

          final monthRecords = records.where((record) =>
              record.date
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              record.date.isBefore(endDate));

          final uniqueDays = monthRecords
              .map((record) => DateTime(
                  record.date.year, record.date.month, record.date.day))
              .toSet()
              .length;
          daysCount = uniqueDays > 0 ? uniqueDays : 1;
        } else {
          // For current month, use actual days in month
          final now = DateTime.now();
          daysCount = DateTime(now.year, now.month + 1, 0).day;
        }
        break;

      case TimePeriod.today:
        // Today is always 1 day
        daysCount = 1;
        break;
    }

    return totalQuantity / daysCount;
  }
}

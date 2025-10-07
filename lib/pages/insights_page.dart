import 'dart:math' as math;

import 'package:dairykhata/models/milk_type_adapter.dart';
import 'package:dairykhata/providers/providers.dart';
import 'package:dairykhata/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordsNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    // Calculate comprehensive insights
    final insights = _calculateInsights(records, settings);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, isSmallScreen ? 60 : 70),
        child: AppBar(
          backgroundColor: const Color(0xff0e2a62).withOpacity(0.8),
          elevation: 0,
          title: Text(
            'Insights',
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
          padding: const EdgeInsets.only(bottom: 86),
          child: records.isEmpty
              ? _buildEmptyState(context, isSmallScreen)
              : _buildInsightsView(context, insights, isSmallScreen),
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
            Icons.insights_outlined,
            size: isSmallScreen ? 80 : 100,
            color: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'No Data Yet',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'Add some milk records to see insights',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsView(
      BuildContext context, Map<String, dynamic> insights, bool isSmallScreen) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Section
            _buildSectionHeader('Overview', isSmallScreen),
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildOverviewCards(insights, isSmallScreen),

            SizedBox(height: isSmallScreen ? 24 : 32),

            // Production Analytics
            _buildSectionHeader('Production Analytics', isSmallScreen),
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildProductionCards(insights, isSmallScreen),

            SizedBox(height: isSmallScreen ? 24 : 32),

            // Milk Type Distribution
            _buildSectionHeader('Milk Type Distribution', isSmallScreen),
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildDistributionCard(insights, isSmallScreen),

            SizedBox(height: isSmallScreen ? 24 : 32),

            // Performance Insights
            _buildSectionHeader('Performance Insights', isSmallScreen),
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildPerformanceCards(insights, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isSmallScreen) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isSmallScreen ? 18 : 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildOverviewCards(
      Map<String, dynamic> insights, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: _buildInsightCard(
            'Total Records',
            insights['totalRecords'].toString(),
            Icons.list_alt,
            Colors.blue,
            isSmallScreen,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: _buildInsightCard(
            'Total Milk',
            '${insights['totalMilk'].toStringAsFixed(1)} L',
            Icons.local_drink,
            Colors.teal,
            isSmallScreen,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: _buildInsightCard(
            'Total Earnings',
            'Rs.${insights['totalEarnings'].toStringAsFixed(0)}',
            Icons.attach_money,
            Colors.green,
            isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildProductionCards(
      Map<String, dynamic> insights, bool isSmallScreen) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                'Avg Daily',
                '${insights['avgDaily'].toStringAsFixed(1)} L/day',
                Icons.trending_up,
                Colors.orange,
                isSmallScreen,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: _buildInsightCard(
                'Best Day',
                '${insights['bestDay']['quantity'].toStringAsFixed(1)} L',
                Icons.star,
                Colors.amber,
                isSmallScreen,
                subtitle:
                    DateFormat('MMM dd').format(insights['bestDay']['date']),
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        _buildInsightCard(
          'Recording Days',
          '${insights['recordingDays']} days',
          Icons.calendar_today,
          Colors.purple,
          isSmallScreen,
          subtitle: 'Days with milk records',
        ),
      ],
    );
  }

  Widget _buildDistributionCard(
      Map<String, dynamic> insights, bool isSmallScreen) {
    final cowPercentage = insights['cowPercentage'];
    final buffaloPercentage = insights['buffaloPercentage'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart,
                    color: Colors.blue, size: isSmallScreen ? 24 : 28),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Text(
                  'Milk Type Breakdown',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Row(
              children: [
                Expanded(
                  flex: cowPercentage.round(),
                  child: Container(
                    height: isSmallScreen ? 40 : 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Cow\n${cowPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: buffaloPercentage.round(),
                  child: Container(
                    height: isSmallScreen ? 40 : 50,
                    decoration: BoxDecoration(
                      color: Colors.brown.withOpacity(0.8),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Buffalo\n${buffaloPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTypeStat(
                    'Cow Milk',
                    '${insights['cowMilk'].toStringAsFixed(1)} L',
                    Colors.blue,
                    isSmallScreen),
                _buildTypeStat(
                    'Buffalo Milk',
                    '${insights['buffaloMilk'].toStringAsFixed(1)} L',
                    Colors.brown,
                    isSmallScreen),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeStat(
      String label, String value, Color color, bool isSmallScreen) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCards(
      Map<String, dynamic> insights, bool isSmallScreen) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                'Consistency',
                '${insights['consistencyScore'].toStringAsFixed(1)}%',
                Icons.show_chart,
                Colors.indigo,
                isSmallScreen,
                subtitle: 'Production stability',
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: _buildInsightCard(
                'Avg Rate',
                'Rs.${insights['avgRate'].toStringAsFixed(0)}/L',
                Icons.currency_rupee,
                Colors.deepOrange,
                isSmallScreen,
                subtitle: 'Average selling price',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon,
      Color color, bool isSmallScreen,
      {String? subtitle}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isSmallScreen ? 28 : 32),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateInsights(
      List<MilkRecord> records, Map<String, dynamic> settings) {
    if (records.isEmpty) {
      return {
        'totalRecords': 0,
        'totalMilk': 0.0,
        'totalEarnings': 0.0,
        'avgDaily': 0.0,
        'bestDay': {'quantity': 0.0, 'date': DateTime.now()},
        'recordingDays': 0,
        'cowMilk': 0.0,
        'buffaloMilk': 0.0,
        'cowPercentage': 0.0,
        'buffaloPercentage': 0.0,
        'consistencyScore': 0.0,
        'avgRate': 0.0,
      };
    }

    // Basic calculations
    final totalRecords = records.length;
    final totalMilk =
        records.fold<double>(0, (sum, record) => sum + record.quantity);

    // Calculate earnings
    final totalEarnings = records.fold<double>(0, (sum, record) {
      final rate = record.type == MilkType.cow
          ? settings['cowMilkRate'] ?? 0.0
          : settings['buffaloMilkRate'] ?? 0.0;
      return sum + (record.quantity * rate);
    });

    // Count unique recording days
    final uniqueDays = records
        .map((record) =>
            DateTime(record.date.year, record.date.month, record.date.day))
        .toSet();
    final recordingDays = uniqueDays.length;

    // Average daily production
    final avgDaily = recordingDays > 0 ? totalMilk / recordingDays : 0.0;

    // Find best day
    final dailyTotals = <DateTime, double>{};
    for (final record in records) {
      final date =
          DateTime(record.date.year, record.date.month, record.date.day);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + record.quantity;
    }
    final bestDayEntry =
        dailyTotals.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Milk type breakdown
    final cowMilk = records
        .where((record) => record.type == MilkType.cow)
        .fold<double>(0, (sum, record) => sum + record.quantity);

    final buffaloMilk = records
        .where((record) => record.type == MilkType.buffalo)
        .fold<double>(0, (sum, record) => sum + record.quantity);

    final cowPercentage = totalMilk > 0 ? (cowMilk / totalMilk) * 100 : 0.0;
    final buffaloPercentage =
        totalMilk > 0 ? (buffaloMilk / totalMilk) * 100 : 0.0;

    // Consistency score (inverse of coefficient of variation)
    final dailyQuantities = dailyTotals.values.toList();
    final consistencyScore = dailyQuantities.length > 1
        ? () {
            final mean = dailyQuantities.reduce((a, b) => a + b) /
                dailyQuantities.length;
            final variance = dailyQuantities
                    .map((q) => (q - mean) * (q - mean))
                    .reduce((a, b) => a + b) /
                dailyQuantities.length;
            final stdDev = variance > 0 ? math.sqrt(variance) : 0.0;
            final cv = mean > 0 ? (stdDev / mean) : 0.0;
            return cv < 1 ? (1 - cv) * 100 : 0.0;
          }()
        : 100.0; // Perfect consistency with one day

    // Average rate calculation
    final avgRate = totalMilk > 0 ? totalEarnings / totalMilk : 0.0;

    return {
      'totalRecords': totalRecords,
      'totalMilk': totalMilk,
      'totalEarnings': totalEarnings,
      'avgDaily': avgDaily,
      'bestDay': {'quantity': bestDayEntry.value, 'date': bestDayEntry.key},
      'recordingDays': recordingDays,
      'cowMilk': cowMilk,
      'buffaloMilk': buffaloMilk,
      'cowPercentage': cowPercentage,
      'buffaloPercentage': buffaloPercentage,
      'consistencyScore': consistencyScore,
      'avgRate': avgRate,
    };
  }
}

import 'package:dairykhata/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _cowRateController;
  late TextEditingController _buffaloRateController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsNotifierProvider);
    _cowRateController = TextEditingController(
      text: settings['cowMilkRate']?.toString() ?? '0.0',
    );
    _buffaloRateController = TextEditingController(
      text: settings['buffaloMilkRate']?.toString() ?? '0.0',
    );
  }

  @override
  void dispose() {
    _cowRateController.dispose();
    _buffaloRateController.dispose();
    super.dispose();
  }

  void _saveRates() {
    final cowRate = double.tryParse(_cowRateController.text) ?? 0.0;
    final buffaloRate = double.tryParse(_buffaloRateController.text) ?? 0.0;

    ref.read(settingsNotifierProvider.notifier).updateCowRate(cowRate);
    ref.read(settingsNotifierProvider.notifier).updateBuffaloRate(buffaloRate);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Milk rates saved successfully!')),
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final weekStartDay = settings['weekStartDay'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: const Text('Milk Rates'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Cow Milk Rate',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: _cowRateController,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buffalo Milk Rate',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: _buffaloRateController,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveRates,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Save Rates'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            title: const Text('Week Start Day'),
            subtitle: Text(_getDayName(weekStartDay)),
            trailing: DropdownButton<int>(
              value: weekStartDay,
              items: [
                const DropdownMenuItem(value: 1, child: Text('Monday')),
                const DropdownMenuItem(value: 2, child: const Text('Tuesday')),
                const DropdownMenuItem(value: 3, child: Text('Wednesday')),
                const DropdownMenuItem(value: 4, child: Text('Thursday')),
                const DropdownMenuItem(value: 5, child: Text('Friday')),
                const DropdownMenuItem(value: 6, child: Text('Saturday')),
                const DropdownMenuItem(value: 7, child: Text('Sunday')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .updateWeekStartDay(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Week start day updated to ${_getDayName(value)}')),
                  );
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(themeMode == ThemeMode.light ? 'Light' : 'Dark'),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeNotifierProvider.notifier).toggleTheme();
              },
            ),
          ),
          const Divider(),
          // Mock settings
          ListTile(
            title: const Text('Language'),
            subtitle: const Text('English (Mock)'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Mock - could show language selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Language selection coming soon!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Export records to file'),
            trailing: const Icon(Icons.download),
            onTap: () {
              // Mock - could export data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('App version and info'),
            trailing: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Dairy Khata',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Dairy Khata Team',
              );
            },
          ),
        ],
      ),
    );
  }
}

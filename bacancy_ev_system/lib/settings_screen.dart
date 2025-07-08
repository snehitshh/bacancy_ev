import 'package:bacancy_ev_system/fault_info_screen.dart';
import 'package:bacancy_ev_system/theme_provider.dart';
import 'package:bacancy_ev_system/modbus/connection_screen.dart';
import 'package:bacancy_ev_system/modbus/modbus_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _localCharging = false;
  bool _testMode = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Change Language'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Fault Information'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const FaultInfoScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.developer_board),
            title: const Text('Firmware Version'),
            subtitle: const Text('v1.0.0'),
            onTap: () {
              _showInfoDialog(context, 'Firmware Version',
                  'You are on the latest version v1.0.0.');
            },
          ),
          SwitchListTile(
            title: const Text('Local Start/Stop Charging'),
            secondary: const Icon(Icons.power_settings_new),
            value: _localCharging,
            onChanged: (bool value) {
              setState(() {
                _localCharging = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Test Mode'),
            secondary: const Icon(Icons.bug_report),
            value: _testMode,
            onChanged: (bool value) {
              setState(() {
                _testMode = value;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.push_pin),
            title: const Text('Pin/Unpin App'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showInfoDialog(context, 'Pin/Unpin App',
                  'This feature is not yet implemented.');
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('Charge Gun-1,2 (QR code)'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showInfoDialog(context, 'QR Code Scanner',
                  'QR code scanner functionality to be implemented.');
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Log Files'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showInfoDialog(context, 'Log Files', 'No new logs.');
            },
          ),
          ListTile(
            leading: const Icon(Icons.usb),
            title: const Text('Configure Serial Port'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showInfoDialog(
                  context, 'Serial Port', 'No serial devices connected.');
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Modbus Connection'),
            subtitle: Consumer<ModbusProvider>(
              builder: (context, modbusProvider, child) {
                return Text(modbusProvider.getConnectionStatusText());
              },
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ModbusConnectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                  title: const Text("English"),
                  value: "en",
                  groupValue: "en",
                  onChanged: (v) {
                    Navigator.of(context).pop();
                  }),
              RadioListTile(
                  title: const Text("Spanish"),
                  value: "es",
                  groupValue: "en",
                  onChanged: (v) {
                    Navigator.of(context).pop();
                  }),
              RadioListTile(
                  title: const Text("French"),
                  value: "fr",
                  groupValue: "en",
                  onChanged: (v) {
                    Navigator.of(context).pop();
                  }),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
} 
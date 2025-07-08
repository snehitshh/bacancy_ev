import 'package:flutter/material.dart';
import 'ac_meter_info_screen.dart';
import 'dc_output_info_screen.dart';
import 'charging_summary_screen.dart';
import 'package:bacancy_ev_system/fault_information_screen.dart';

class GunInfoScreen extends StatefulWidget {
  final String gunLabel;

  const GunInfoScreen({super.key, required this.gunLabel});

  @override
  State<GunInfoScreen> createState() => _GunInfoScreenState();
}

class _GunInfoScreenState extends State<GunInfoScreen> {
  // Placeholder data
  final double initialSOC = 20.0;
  final double chargingSOC = 75.0;
  final double demandVoltage = 230.0;
  final double chargingCurrent = 16.0;
  final double demandCurrent = 16.5;
  final Duration chargingDuration = const Duration(minutes: 45, seconds: 30);
  final double chargingVoltage = 228.0;
  final double energyConsumption = 8.5;
  final double gunTemperature = 45.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gunLabel),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildInfoTile('Initial SOC', '$initialSOC %', Icons.battery_1_bar),
                  _buildInfoTile('Charging SOC', '$chargingSOC %', Icons.battery_charging_full),
                  _buildInfoTile('Demand Voltage', '$demandVoltage V', Icons.power),
                  _buildInfoTile('Charging Current', '$chargingCurrent A', Icons.flash_on),
                  _buildInfoTile('Demand Current', '$demandCurrent A', Icons.flash_on_outlined),
                  _buildInfoTile('Duration', _formatDuration(chargingDuration), Icons.timer),
                  _buildInfoTile('Charging Voltage', '$chargingVoltage V', Icons.power_settings_new),
                  _buildInfoTile('Energy Consumption', '$energyConsumption kWh', Icons.ev_station),
                  _buildInfoTile('Gun Temperature', '$gunTemperature °C', Icons.thermostat),
                  
                  // Information buttons section
                  const SizedBox(height: 20),
                  Text(
                    'System Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInformationButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).primaryColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        trailing: Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor)),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  Widget _buildInformationButtons(BuildContext context) {
    final List<Map<String, dynamic>> infoButtons = [
      {
        'title': 'AC Meter Information',
        'icon': Icons.electric_meter,
        'color': Colors.blue,
      },
      {
        'title': 'DC Output Information',
        'icon': Icons.battery_charging_full,
        'color': Colors.purple,
      },
      {
        'title': 'Charging Summary',
        'icon': Icons.summarize,
        'color': Colors.teal,
      },
      {
        'title': 'Fault Information',
        'icon': Icons.warning,
        'color': Colors.red,
      },
    ];

    return Column(
      children: [
        // First row of buttons
        Row(
          children: [
            Expanded(child: _buildInfoButton(context, infoButtons[0])),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoButton(context, infoButtons[1])),
          ],
        ),
        const SizedBox(height: 8),
        // Second row of buttons
        Row(
          children: [
            Expanded(child: _buildInfoButton(context, infoButtons[2])),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoButton(context, infoButtons[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoButton(BuildContext context, Map<String, dynamic> buttonData) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = buttonData['color'] as Color;
    final iconColor = isDarkMode
        ? Theme.of(context).colorScheme.onSurface
        : color;
    final textColor = isDarkMode
        ? Theme.of(context).colorScheme.onSurface
        : color;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [color.withOpacity(0.25), color.withOpacity(0.10)]
              : [color.withOpacity(0.10), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? color.withOpacity(0.4) : color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to respective screens based on button title
            if (buttonData['title'] == 'AC Meter Information') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ACMeterInfoScreen(),
                ),
              );
            } else if (buttonData['title'] == 'DC Output Information') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DCOutputInfoScreen(),
                ),
              );
            } else if (buttonData['title'] == 'Charging Summary') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChargingSummaryScreen(),
                ),
              );
            } else if (buttonData['title'] == 'Fault Information') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FaultInformationScreen(),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  buttonData['icon'],
                  color: iconColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  buttonData['title'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
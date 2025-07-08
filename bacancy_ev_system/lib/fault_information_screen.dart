import 'package:bacancy_ev_system/communication_error_screen.dart';
import 'package:bacancy_ev_system/device_connection_status_screen.dart';
import 'package:bacancy_ev_system/plc_faults_screen.dart';
import 'package:bacancy_ev_system/rectifier_faults_screen.dart';
import 'package:flutter/material.dart';

class FaultInformationScreen extends StatelessWidget {
  const FaultInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fault Information'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFaultButton(
                      context,
                      title: 'PLC Faults',
                      icon: Icons.electrical_services,
                      color: Colors.orange,
                      screen: const PLCFaultsScreen(),
                    ),
                    _buildFaultButton(
                      context,
                      title: 'Rectifier Faults',
                      icon: Icons.power_off,
                      color: Colors.blue,
                      screen: const RectifierFaultsScreen(),
                    ),
                    _buildFaultButton(
                      context,
                      title: 'Communication Error',
                      icon: Icons.wifi_off,
                      color: Colors.purple,
                      screen: const CommunicationErrorScreen(),
                    ),
                    _buildFaultButton(
                      context,
                      title: 'Miscellaneous Error',
                      icon: Icons.error,
                      color: Colors.green,
                      screen: const DeviceConnectionStatusScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode
        ? Theme.of(context).colorScheme.onError
        : Colors.red.shade700;
    final titleColor = isDarkMode
        ? Theme.of(context).colorScheme.onError
        : Colors.red.shade800;
    final descColor = isDarkMode
        ? Theme.of(context).colorScheme.onError.withOpacity(0.7)
        : Colors.red.shade600;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.red.withOpacity(0.15) : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.red.withOpacity(0.3) : Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning,
            size: 48,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Fault Categories',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a category to view detailed faults',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: descColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaultButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode
        ? Theme.of(context).colorScheme.onSurface
        : color;
    final textColor = isDarkMode
        ? Theme.of(context).colorScheme.onSurface
        : color;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [color.withOpacity(0.20), color.withOpacity(0.08)]
                  : [color.withOpacity(0.10), Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: iconColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';

class ChargingSummaryScreen extends StatefulWidget {
  const ChargingSummaryScreen({super.key});

  @override
  State<ChargingSummaryScreen> createState() => _ChargingSummaryScreenState();
}

class _ChargingSummaryScreenState extends State<ChargingSummaryScreen> {
  // Placeholder data for charging summary
  final Map<String, dynamic> chargingSummaryData = {
    'EV Mac Address': 'AA:BB:CC:DD:EE:FF',
    'Charging Duration': '02:15:30',
    'Charging Start Date & Time': '2024-01-15 14:30:25',
    'Charging End Date & Time': '2024-01-15 16:45:55',
    'Start SoC': '25.0',
    'End SoC': '85.0',
    'Energy Consumption': '45.8',
    'Session End Reason': 'Target SoC Reached',
    'Total Cost': '950.75',
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Summary'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: isDarkMode
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.teal.shade50,
                    Colors.white,
                  ],
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.summarize,
                      size: 48,
                      color: Colors.teal.shade700,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Charging Session Summary',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete charging session details',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.teal.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Parameters section
              Expanded(
                child: ListView(
                  children: [
                    _buildParameterSection('Session Information', [
                      'EV Mac Address',
                      'Charging Duration',
                      'Session End Reason',
                    ], Icons.info, Colors.blue),
                    
                    const SizedBox(height: 16),
                    
                    _buildParameterSection('Time Details', [
                      'Charging Start Date & Time',
                      'Charging End Date & Time',
                    ], Icons.schedule, Colors.orange),
                    
                    const SizedBox(height: 16),
                    
                    _buildParameterSection('Battery Status', [
                      'Start SoC',
                      'End SoC',
                    ], Icons.battery_charging_full, Colors.green),
                    
                    const SizedBox(height: 16),
                    
                    _buildParameterSection('Energy & Cost', [
                      'Energy Consumption',
                      'Total Cost',
                    ], Icons.attach_money, Colors.purple),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterSection(String title, List<String> parameters, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...parameters.map((param) => _buildParameterTile(param, chargingSummaryData[param] ?? '')),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterTile(String title, dynamic value) {
    String unit = _getUnit(title);
    String formattedValue = _formatValue(value, unit);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formattedValue,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _getUnit(String parameter) {
    if (parameter.contains('SoC')) return '%';
    if (parameter.contains('Energy Consumption')) return 'kWh';
    if (parameter.contains('Total Cost')) return 'INR';
    if (parameter.contains('Duration')) return 'time';
    return '';
  }

  String _formatValue(dynamic value, String unit) {
    if (unit == '%') {
      return '$value%';
    } else if (unit == 'kWh') {
      return '$value kWh';
    } else if (unit == 'INR') {
      return '₹$value';
    } else if (unit == 'time') {
      return value; // Duration is already formatted
    } else {
      return value.toString();
    }
  }
} 
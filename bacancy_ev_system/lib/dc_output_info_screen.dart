import 'package:flutter/material.dart';

class DCOutputInfoScreen extends StatefulWidget {
  const DCOutputInfoScreen({super.key});

  @override
  State<DCOutputInfoScreen> createState() => _DCOutputInfoScreenState();
}

class _DCOutputInfoScreenState extends State<DCOutputInfoScreen> {
  // Placeholder data for DC output readings
  final Map<String, double> dcOutputData = {
    'Voltage': 400.5,
    'Max Voltage': 450.0,
    'Min Voltage': 350.0,
    'Current': 25.8,
    'Max Current': 32.0,
    'Min Current': 5.0,
    'Power': 10.3,
    'Import Energy': 850.2,
    'Export Energy': 125.5,
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('DC Output Information'),
        backgroundColor: Colors.purple,
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
                    Colors.purple.shade50,
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
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.battery_charging_full,
                      size: 48,
                      color: Colors.purple.shade700,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'DC Output Readings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time DC electrical parameters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.purple.shade600,
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
                    _buildParameterSection('Voltage Parameters', [
                      'Voltage',
                      'Max Voltage',
                      'Min Voltage',
                    ], Icons.power, Colors.red),
                    
                    const SizedBox(height: 16),
                    
                    _buildParameterSection('Current Parameters', [
                      'Current',
                      'Max Current',
                      'Min Current',
                    ], Icons.flash_on, Colors.orange),
                    
                    const SizedBox(height: 16),
                    
                    _buildParameterSection('Power & Energy', [
                      'Power',
                      'Import Energy',
                      'Export Energy',
                    ], Icons.ev_station, Colors.green),
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
            ...parameters.map((param) => _buildParameterTile(param, dcOutputData[param] ?? 0.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterTile(String title, double value) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            formattedValue,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _getUnit(String parameter) {
    if (parameter.contains('Voltage')) return 'V';
    if (parameter.contains('Current')) return 'A';
    if (parameter.contains('Power')) return 'kW';
    if (parameter.contains('Energy')) return 'kWh';
    return '';
  }

  String _formatValue(double value, String unit) {
    if (unit == 'kWh') {
      return '${value.toStringAsFixed(1)} $unit';
    } else if (unit == 'kW') {
      return '${value.toStringAsFixed(1)} $unit';
    } else {
      return '${value.toStringAsFixed(1)} $unit';
    }
  }
} 
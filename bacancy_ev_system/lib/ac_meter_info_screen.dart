import 'package:flutter/material.dart';

class ACMeterInfoScreen extends StatefulWidget {
  const ACMeterInfoScreen({super.key});

  @override
  State<ACMeterInfoScreen> createState() => _ACMeterInfoScreenState();
}

class _ACMeterInfoScreenState extends State<ACMeterInfoScreen> {
  // Placeholder data for AC meter readings
  final Map<String, double> acMeterData = {
    'Voltage V1N': 230.5,
    'Voltage V2N': 231.2,
    'Voltage V3N': 229.8,
    'Avg Voltage LN': 230.5,
    'Frequency(Hz)': 50.0,
    'Current I1': 15.8,
    'Current I2': 16.2,
    'Current I3': 15.9,
    'Avg Current': 16.0,
    'Active Power': 11.2,
    'Total Export Energy': 1250.5,
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AC Meter Information'),
        backgroundColor: Colors.blue,
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
                    Colors.blue.shade50,
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
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.electric_meter,
                      size: 48,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AC Meter Readings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time electrical parameters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade600,
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
                      'Voltage V1N',
                      'Voltage V2N', 
                      'Voltage V3N',
                      'Avg Voltage LN',
                    ], Icons.power, Colors.red),
                    
                    const SizedBox(height: 16),
                    
                    _buildParameterSection('Current Parameters', [
                      'Current I1',
                      'Current I2',
                      'Current I3',
                      'Avg Current',
                    ], Icons.flash_on, Colors.orange),
                    
                    const SizedBox(height: 16),
                    
                    _buildParameterSection('Power & Energy', [
                      'Frequency(Hz)',
                      'Active Power',
                      'Total Export Energy',
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
            ...parameters.map((param) => _buildParameterTile(param, acMeterData[param] ?? 0.0)),
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
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _getUnit(String parameter) {
    if (parameter.contains('Voltage')) return 'V';
    if (parameter.contains('Current')) return 'A';
    if (parameter.contains('Frequency')) return 'Hz';
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
import 'package:flutter/material.dart';
import 'dart:math';

class RectifierFaultsScreen extends StatelessWidget {
  const RectifierFaultsScreen({super.key});

  // Generate random error codes for demonstration
  String _getRandomErrorCode() {
    final random = Random();
    final isFault = random.nextBool();
    if (!isFault) return 'No Fault';
    return 'ERR-${random.nextInt(1000).toString().padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> rectifiers = [
      {'name': 'Rectifier 1', 'errorCode': _getRandomErrorCode()},
      {'name': 'Rectifier 2', 'errorCode': _getRandomErrorCode()},
      {'name': 'Rectifier 3', 'errorCode': _getRandomErrorCode()},
      {'name': 'Rectifier 4', 'errorCode': _getRandomErrorCode()},
    ];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rectifier Faults'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            ...rectifiers.map((rectifier) {
              return _buildRectifierTile(
                context,
                title: rectifier['name']!,
                errorCode: rectifier['errorCode']!,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.power_off, size: 48, color: Colors.blue.shade700),
          const SizedBox(height: 8),
          Text(
            'Rectifier Error Codes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRectifierTile(BuildContext context, {required String title, required String errorCode}) {
    final bool hasError = errorCode != 'No Fault';
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: Icon(
          Icons.power_settings_new,
          color: hasError ? Colors.red.shade400 : Colors.green.shade400,
          size: 40,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          errorCode,
          style: TextStyle(
            color: hasError ? Colors.red.shade700 : Colors.green.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 
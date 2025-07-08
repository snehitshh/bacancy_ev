import 'package:flutter/material.dart';

class PLCFaultsScreen extends StatelessWidget {
  const PLCFaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final Map<String, bool> gunFaultStatus = {
      'Gun 1': false, // false = no fault (Green)
      'Gun 2': true, // true = fault (Red)
    };
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLC Faults'),
        backgroundColor: Colors.orange,
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
                    Colors.orange.shade50,
                    Colors.white,
                  ],
                ),
              ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            ...gunFaultStatus.entries.map((entry) {
              return _buildFaultStatusTile(
                context,
                title: entry.key,
                hasFault: entry.value,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.electrical_services, size: 48, color: Colors.orange.shade700),
          const SizedBox(height: 8),
          Text(
            'PLC Fault Status',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaultStatusTile(BuildContext context, {required String title, required bool hasFault}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: Container(
          width: 100,
          height: 40,
          decoration: BoxDecoration(
            color: hasFault ? Colors.red.shade400 : Colors.green.shade400,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: (hasFault ? Colors.red : Colors.green).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              hasFault ? 'FAULT' : 'OK',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
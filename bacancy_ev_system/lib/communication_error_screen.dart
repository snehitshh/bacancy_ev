import 'package:flutter/material.dart';
import 'dart:math';

class CommunicationErrorScreen extends StatelessWidget {
  const CommunicationErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data
    final Map<String, bool> communicationStatus = {
      'PLC Communication Error': false,
      'Rectifier Communication Error': true,
      'OCPP Communication Error': false,
      'Modbus Master Communication Error': false,
    };
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication Errors'),
        backgroundColor: Colors.purple,
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
                    Colors.purple.shade50,
                    Colors.white,
                  ],
                ),
              ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildStatusTable(context, communicationStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.purple.shade700),
          const SizedBox(height: 8),
          Text(
            'Communication Status',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTable(BuildContext context, Map<String, bool> statusMap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          children: [
            _buildTableHeader(context),
            ...statusMap.entries.map((entry) {
              return _buildTableRow(context, title: entry.key, hasFault: entry.value);
            }),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader(BuildContext context) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Fault Type Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Status',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(BuildContext context, {required String title, required bool hasFault}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasFault ? Colors.red.shade400 : Colors.green.shade400,
                boxShadow: [
                  BoxShadow(
                    color: (hasFault ? Colors.red : Colors.green).withOpacity(0.5),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 
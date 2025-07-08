import 'package:flutter/material.dart';

class FaultInfoScreen extends StatelessWidget {
  const FaultInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fault Information'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Sr. No.')),
            DataColumn(label: Text('Error Time')),
            DataColumn(label: Text('Error Description')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Source')),
          ],
          rows: <DataRow>[
            DataRow(cells: <DataCell>[
              const DataCell(Text('1')),
              DataCell(Text(DateTime.now().subtract(const Duration(hours: 1)).toString())),
              const DataCell(Text('Over-current detected')),
              const DataCell(Text('Occurred')),
              const DataCell(Text('Gun 1')),
            ]),
            DataRow(cells: <DataCell>[
              const DataCell(Text('2')),
              DataCell(Text(DateTime.now().subtract(const Duration(minutes: 30)).toString())),
              const DataCell(Text('Under-voltage detected')),
              const DataCell(Text('Resolved')),
              const DataCell(Text('Charger')),
            ]),
            DataRow(cells: <DataCell>[
              const DataCell(Text('3')),
              DataCell(Text(DateTime.now().subtract(const Duration(minutes: 5)).toString())),
              const DataCell(Text('Emergency stop pressed')),
              const DataCell(Text('Occurred')),
              const DataCell(Text('Gun 2')),
            ]),
          ],
        ),
      ),
    );
  }
} 
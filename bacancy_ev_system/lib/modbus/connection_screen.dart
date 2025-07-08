import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'modbus_provider.dart';
import 'modbus_data_models.dart';
// import 'android_serial_port_finder.dart';

class ModbusConnectionScreen extends StatefulWidget {
  const ModbusConnectionScreen({super.key});

  @override
  State<ModbusConnectionScreen> createState() => _ModbusConnectionScreenState();
}

class _ModbusConnectionScreenState extends State<ModbusConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _devicePathController = TextEditingController();
  int _selectedBaudRate = 9600;
  bool _isConnecting = false;
  bool _isScanning = false;
  List<String> _availableDevices = [];
  List<Map<String, dynamic>> _deviceDetails = [];
  
  final List<int> _baudRates = [9600, 19200, 38400, 57600, 115200];

  @override
  void initState() {
    super.initState();
    _devicePathController.text = '/dev/ttyUSB0'; // Default device path
    _scanForDevices();
  }

  @override
  void dispose() {
    _devicePathController.dispose();
    super.dispose();
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Get available devices
      final devices = <String>["/dev/ttyUSB0", "/dev/ttyUSB1"];
      final deviceDetails = <Map<String, dynamic>>[];
      
      setState(() {
        _availableDevices = devices;
        _deviceDetails = deviceDetails;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning for devices: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modbus Connection'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isScanning 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanForDevices,
            tooltip: 'Scan for devices',
          ),
        ],
      ),
      body: Consumer<ModbusProvider>(
        builder: (context, modbusProvider, child) {
          return Container(
            decoration: BoxDecoration(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildConnectionStatusCard(modbusProvider),
                  const SizedBox(height: 20),
                  _buildConnectionForm(modbusProvider),
                  const SizedBox(height: 20),
                  _buildAvailableDevicesCard(),
                  const SizedBox(height: 20),
                  _buildErrorCard(modbusProvider),
                  const SizedBox(height: 20),
                  _buildConnectionControls(modbusProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatusCard(ModbusProvider modbusProvider) {
    final status = modbusProvider.connectionStatus;
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              statusIcon,
              size: 48,
              color: statusColor,
            ),
            const SizedBox(height: 8),
            Text(
              'Connection Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              modbusProvider.getConnectionStatusText(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: statusColor,
              ),
            ),
            if (modbusProvider.isConnected()) ...[
              const SizedBox(height: 8),
              Text(
                'Device: ${modbusProvider.devicePath}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Baud Rate: ${modbusProvider.baudRate}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionForm(ModbusProvider modbusProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connection Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 16),
              
              // Device Path with Dropdown
              DropdownButtonFormField<String>(
                value: _availableDevices.contains(_devicePathController.text) 
                  ? _devicePathController.text 
                  : null,
                decoration: const InputDecoration(
                  labelText: 'Device Path',
                  hintText: 'Select or enter device path',
                  prefixIcon: Icon(Icons.device_hub),
                  border: OutlineInputBorder(),
                ),
                items: [
                  ..._availableDevices.map((device) => DropdownMenuItem<String>(
                    value: device,
                    child: Text(device),
                  )),
                  if (!_availableDevices.contains(_devicePathController.text))
                    DropdownMenuItem<String>(
                      value: _devicePathController.text,
                      child: Text('${_devicePathController.text} (Custom)'),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _devicePathController.text = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select or enter device path';
                  }
                  if (!(value == "/dev/ttyUSB0" || value == "/dev/ttyUSB1")) {
                    return 'Invalid device path format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Manual Device Path Input
              TextFormField(
                controller: _devicePathController,
                decoration: const InputDecoration(
                  labelText: 'Custom Device Path',
                  hintText: 'Enter custom device path',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device path';
                  }
                  if (!(value == "/dev/ttyUSB0" || value == "/dev/ttyUSB1")) {
                    return 'Invalid device path format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Baud Rate
              DropdownButtonFormField<int>(
                value: _selectedBaudRate,
                decoration: const InputDecoration(
                  labelText: 'Baud Rate',
                  prefixIcon: Icon(Icons.speed),
                  border: OutlineInputBorder(),
                ),
                items: _baudRates.map((baudRate) {
                  return DropdownMenuItem<int>(
                    value: baudRate,
                    child: Text('$baudRate'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBaudRate = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Common Device Paths
              Text(
                'Quick Selection:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [Text("/dev/ttyUSB0"), Text("/dev/ttyUSB1")],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableDevicesCard() {
    if (_availableDevices.isEmpty && !_isScanning) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Available Devices',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const Spacer(),
                if (_isScanning)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_availableDevices.isNotEmpty) ...[
              ..._availableDevices.map((device) => _buildDeviceTile(device)),
            ] else if (!_isScanning) ...[
              Text(
                'No devices found. Try refreshing or check your connections.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTile(String device) {
    final deviceInfo = _deviceDetails.firstWhere(
      (info) => info['path'] == device || device.contains(info['name'] ?? ''),
      orElse: () => <String, dynamic>{},
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.device_hub,
        color: deviceInfo['readable'] == true ? Colors.green : Colors.grey,
      ),
      title: Text(
        device,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: deviceInfo['readable'] == true ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: deviceInfo.isNotEmpty 
        ? Text(
            'Readable: ${deviceInfo['readable'] == true ? 'Yes' : 'No'} | Writable: ${deviceInfo['writable'] == true ? 'Yes' : 'No'}',
            style: TextStyle(fontSize: 12),
          )
        : null,
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: () {
          setState(() {
            _devicePathController.text = device;
          });
        },
      ),
    );
  }

  Widget _buildDevicePathChip(String devicePath) {
    return ActionChip(
      label: Text(devicePath),
      onPressed: () {
        setState(() {
          _devicePathController.text = devicePath;
        });
      },
      backgroundColor: Colors.blue.shade50,
      labelStyle: TextStyle(color: Colors.blue.shade700),
    );
  }

  Widget _buildErrorCard(ModbusProvider modbusProvider) {
    if (!modbusProvider.hasError()) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Connection Error',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              modbusProvider.lastError?.message ?? 'Unknown error',
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    modbusProvider.clearErrorHistory();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Errors'),
                ),
                const Spacer(),
                Text(
                  '${modbusProvider.errorHistory.length} errors',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionControls(ModbusProvider modbusProvider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: modbusProvider.isConnected() ? null : _connect,
            icon: _isConnecting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link),
            label: Text(_isConnecting ? 'Connecting...' : 'Connect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: modbusProvider.isConnected() ? _disconnect : null,
            icon: const Icon(Icons.link_off),
            label: const Text('Disconnect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      final modbusProvider = Provider.of<ModbusProvider>(context, listen: false);
      final success = await modbusProvider.connect(
        _devicePathController.text,
        baudRate: _selectedBaudRate,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully connected to device'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to connect to device'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  void _disconnect() {
    final modbusProvider = Provider.of<ModbusProvider>(context, listen: false);
    modbusProvider.disconnect();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disconnected from device'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Color _getStatusColor(ModbusConnectionStatus status) {
    switch (status) {
      case ModbusConnectionStatus.disconnected:
        return Colors.grey;
      case ModbusConnectionStatus.connecting:
        return Colors.orange;
      case ModbusConnectionStatus.connected:
        return Colors.green;
      case ModbusConnectionStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ModbusConnectionStatus status) {
    switch (status) {
      case ModbusConnectionStatus.disconnected:
        return Icons.link_off;
      case ModbusConnectionStatus.connecting:
        return Icons.hourglass_empty;
      case ModbusConnectionStatus.connected:
        return Icons.link;
      case ModbusConnectionStatus.error:
        return Icons.error;
    }
  }
} 
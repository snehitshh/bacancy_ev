import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';
import 'modbus_data_models.dart';
import '../queue_models.dart';

class ModbusProtocol {
  static const int MODBUS_TCP_PORT = 502;
  static const int MODBUS_RTU_SLAVE_ID = 1;
  
  // Modbus Function Codes
  static const int READ_COILS = 0x01;
  static const int READ_DISCRETE_INPUTS = 0x02;
  static const int READ_HOLDING_REGISTERS = 0x03;
  static const int READ_INPUT_REGISTERS = 0x04;
  static const int WRITE_SINGLE_COIL = 0x05;
  static const int WRITE_SINGLE_REGISTER = 0x06;
  static const int WRITE_MULTIPLE_COILS = 0x0F;
  static const int WRITE_MULTIPLE_REGISTERS = 0x10;

  // Register Addresses for EV System
  static const Map<String, int> REGISTER_ADDRESSES = {
    // Gun Information
    'gun_status': 0x0001,
    'initial_soc': 0x0002,
    'charging_soc': 0x0003,
    'demand_voltage': 0x0004,
    'charging_current': 0x0005,
    'demand_current': 0x0006,
    'charging_voltage': 0x0007,
    'energy_consumption': 0x0008,
    'gun_temperature': 0x0009,
    'charging_duration_seconds': 0x000A,
    
    // AC Meter Information
    'voltage_v1n': 0x0100,
    'voltage_v2n': 0x0101,
    'voltage_v3n': 0x0102,
    'avg_voltage_ln': 0x0103,
    'frequency_hz': 0x0104,
    'current_i1': 0x0105,
    'current_i2': 0x0106,
    'current_i3': 0x0107,
    'avg_current': 0x0108,
    'active_power': 0x0109,
    'total_export_energy': 0x010A,
    
    // DC Output Information
    'dc_voltage': 0x0200,
    'dc_max_voltage': 0x0201,
    'dc_min_voltage': 0x0202,
    'dc_current': 0x0203,
    'dc_max_current': 0x0204,
    'dc_min_current': 0x0205,
    'dc_power': 0x0206,
    'dc_import_energy': 0x0207,
    'dc_export_energy': 0x0208,
    
    // Charging Summary
    'ev_mac_address_high': 0x0300,
    'ev_mac_address_low': 0x0301,
    'charging_start_time': 0x0302,
    'charging_end_time': 0x0303,
    'start_soc': 0x0304,
    'end_soc': 0x0305,
    'session_energy_consumption': 0x0306,
    'session_end_reason': 0x0307,
    'total_cost': 0x0308,
    
    // Fault Information
    'plc_fault_gun1': 0x0400,
    'plc_fault_gun2': 0x0401,
    'rectifier_faults': 0x0402,
    'communication_errors': 0x0403,
    'miscellaneous_errors': 0x0404,
    
    // System Status
    'system_status': 0x0500,
    'connection_status': 0x0501,
    'device_online': 0x0502,
  };

  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  final StreamController<ModbusData> _dataController = StreamController<ModbusData>.broadcast();
  
  Stream<ModbusData> get dataStream => _dataController.stream;

  // Connection management
  Future<bool> connectToDevice(String devicePath, {int baudRate = 9600}) async {
    try {
      List<UsbDevice> devices = await UsbSerial.listDevices();
      UsbPort? port;
      for (final device in devices) {
        // You may want to match by device.deviceId, productName, etc.
        // For now, use the first device
        port = await device.create();
        break;
      }
      if (port != null && await port.open()) {
        await port.setDTR(true);
        await port.setRTS(true);
        await port.setPortParameters(
          baudRate,
          UsbPort.DATABITS_8,
          UsbPort.STOPBITS_1,
          UsbPort.PARITY_NONE,
        );
        _port = port;
        _subscription = _port!.inputStream!.listen(_handleIncomingData);
        return true;
      }
    } catch (e) {
      print('Error connecting to device: $e');
    }
    return false;
  }

  void disconnect() {
    _subscription?.cancel();
    _port?.close();
    _port = null;
  }

  // Data reading methods
  Future<double> readRegister(String registerName) async {
    final address = REGISTER_ADDRESSES[registerName];
    if (address == null) {
      throw Exception('Register $registerName not found');
    }
    
    final response = await _sendModbusRequest(READ_HOLDING_REGISTERS, address, 1);
    if (response != null && response.length >= 3) {
      return _bytesToFloat(response.sublist(1, 3));
    }
    throw Exception('Failed to read register $registerName');
  }

  Future<List<double>> readMultipleRegisters(String startRegister, int count) async {
    final address = REGISTER_ADDRESSES[startRegister];
    if (address == null) {
      throw Exception('Register $startRegister not found');
    }
    
    final response = await _sendModbusRequest(READ_HOLDING_REGISTERS, address, count);
    if (response != null && response.length >= 1 + count * 2) {
      final values = <double>[];
      for (int i = 0; i < count; i++) {
        final offset = 1 + i * 2;
        values.add(_bytesToFloat(response.sublist(offset, offset + 2)));
      }
      return values;
    }
    throw Exception('Failed to read multiple registers');
  }

  Future<bool> readCoil(String coilName) async {
    final address = REGISTER_ADDRESSES[coilName];
    if (address == null) {
      throw Exception('Coil $coilName not found');
    }
    
    final response = await _sendModbusRequest(READ_COILS, address, 1);
    if (response != null && response.length >= 2) {
      return response[1] != 0;
    }
    throw Exception('Failed to read coil $coilName');
  }

  // Data writing methods
  Future<bool> writeRegister(String registerName, double value) async {
    final address = REGISTER_ADDRESSES[registerName];
    if (address == null) {
      throw Exception('Register $registerName not found');
    }
    
    final bytes = _floatToBytes(value);
    final response = await _sendModbusRequest(WRITE_SINGLE_REGISTER, address, 1, data: bytes);
    return response != null;
  }

  Future<bool> writeCoil(String coilName, bool value) async {
    final address = REGISTER_ADDRESSES[coilName];
    if (address == null) {
      throw Exception('Coil $coilName not found');
    }
    
    final data = Uint8List.fromList([value ? 0xFF00 : 0x0000]);
    final response = await _sendModbusRequest(WRITE_SINGLE_COIL, address, 1, data: data);
    return response != null;
  }

  // High-level data reading methods for specific screens
  Future<GunInfoData> readGunInfo(String gunId) async {
    final baseAddress = gunId == 'Gun 1' ? 0x0001 : 0x0010;
    
    final registers = await readMultipleRegisters('gun_status', 9);
    
    return GunInfoData(
      gunId: gunId,
      status: GunStatus.values[registers[0].toInt()],
      initialSOC: registers[1],
      chargingSOC: registers[2],
      demandVoltage: registers[3],
      chargingCurrent: registers[4],
      demandCurrent: registers[5],
      chargingVoltage: registers[6],
      energyConsumption: registers[7],
      gunTemperature: registers[8],
      chargingDuration: Duration(seconds: registers[9].toInt()),
    );
  }

  Future<ACMeterData> readACMeterInfo() async {
    final registers = await readMultipleRegisters('voltage_v1n', 11);
    
    return ACMeterData(
      voltageV1N: registers[0],
      voltageV2N: registers[1],
      voltageV3N: registers[2],
      avgVoltageLN: registers[3],
      frequencyHz: registers[4],
      currentI1: registers[5],
      currentI2: registers[6],
      currentI3: registers[7],
      avgCurrent: registers[8],
      activePower: registers[9],
      totalExportEnergy: registers[10],
    );
  }

  Future<DCOutputData> readDCOutputInfo() async {
    final registers = await readMultipleRegisters('dc_voltage', 9);
    
    return DCOutputData(
      voltage: registers[0],
      maxVoltage: registers[1],
      minVoltage: registers[2],
      current: registers[3],
      maxCurrent: registers[4],
      minCurrent: registers[5],
      power: registers[6],
      importEnergy: registers[7],
      exportEnergy: registers[8],
    );
  }

  Future<ChargingSummaryData> readChargingSummary() async {
    final registers = await readMultipleRegisters('ev_mac_address_high', 9);
    
    return ChargingSummaryData(
      evMacAddress: _formatMacAddress(registers[0], registers[1]),
      chargingDuration: Duration(seconds: registers[2].toInt()),
      chargingStartTime: DateTime.fromMillisecondsSinceEpoch(registers[3].toInt() * 1000),
      chargingEndTime: DateTime.fromMillisecondsSinceEpoch(registers[4].toInt() * 1000),
      startSOC: registers[5],
      endSOC: registers[6],
      energyConsumption: registers[7],
      sessionEndReason: _getSessionEndReason(registers[8].toInt()),
      totalCost: registers[9],
    );
  }

  Future<FaultData> readFaultInfo() async {
    final registers = await readMultipleRegisters('plc_fault_gun1', 5);
    
    return FaultData(
      plcFaultGun1: registers[0] != 0,
      plcFaultGun2: registers[1] != 0,
      rectifierFaults: registers[2].toInt(),
      communicationErrors: registers[3].toInt(),
      miscellaneousErrors: registers[4].toInt(),
    );
  }

  // Helper methods
  Future<Uint8List?> _sendModbusRequest(int functionCode, int address, int count, {Uint8List? data}) async {
    if (_port == null) return null;
    
    final transaction = Transaction.stringTerminated(
      _port!.inputStream!,
      Uint8List.fromList([0x0D, 0x0A]),
    );
    
    final request = _buildModbusRequest(functionCode, address, count, data: data);
    await _port!.write(request);
    
    try {
      final response = await transaction.stream.first.timeout(const Duration(seconds: 5));
      return Uint8List.fromList(response.codeUnits);
    } catch (e) {
      print('Modbus request timeout: $e');
      return null;
    }
  }

  Uint8List _buildModbusRequest(int functionCode, int address, int count, {Uint8List? data}) {
    final buffer = ByteData(256);
    int offset = 0;
    
    // Transaction ID (2 bytes)
    buffer.setUint16(offset, 0x0001, Endian.big);
    offset += 2;
    
    // Protocol ID (2 bytes) - 0 for Modbus
    buffer.setUint16(offset, 0x0000, Endian.big);
    offset += 2;
    
    // Length (2 bytes) - will be set later
    final lengthOffset = offset;
    offset += 2;
    
    // Unit ID (1 byte)
    buffer.setUint8(offset, MODBUS_RTU_SLAVE_ID);
    offset += 1;
    
    // Function Code (1 byte)
    buffer.setUint8(offset, functionCode);
    offset += 1;
    
    // Address (2 bytes)
    buffer.setUint16(offset, address, Endian.big);
    offset += 2;
    
    // Count/Data (2 bytes)
    buffer.setUint16(offset, count, Endian.big);
    offset += 2;
    
    // Additional data if provided
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        buffer.setUint8(offset + i, data[i]);
      }
      offset += data.length;
    }
    
    // Set length
    buffer.setUint16(lengthOffset, offset - 6, Endian.big);
    
    return buffer.buffer.asUint8List(0, offset);
  }

  void _handleIncomingData(Uint8List data) {
    // Parse incoming Modbus data and emit to stream
    try {
      final modbusData = _parseModbusResponse(data);
      if (modbusData != null) {
        _dataController.add(modbusData);
      }
    } catch (e) {
      print('Error parsing Modbus data: $e');
    }
  }

  ModbusData? _parseModbusResponse(Uint8List data) {
    if (data.length < 9) return null;
    
    final functionCode = data[7];
    final dataLength = data[8];
    
    if (data.length < 9 + dataLength) return null;
    
    final responseData = data.sublist(9, 9 + dataLength);
    
    return ModbusData(
      functionCode: functionCode,
      data: responseData,
      timestamp: DateTime.now(),
    );
  }

  double _bytesToFloat(Uint8List bytes) {
    if (bytes.length < 2) return 0.0;
    final value = (bytes[0] << 8) | bytes[1];
    return value / 100.0; // Assuming 2 decimal places
  }

  Uint8List _floatToBytes(double value) {
    final intValue = (value * 100).round();
    return Uint8List.fromList([
      (intValue >> 8) & 0xFF,
      intValue & 0xFF,
    ]);
  }

  String _formatMacAddress(double high, double low) {
    final highInt = high.toInt();
    final lowInt = low.toInt();
    // Format as 6-byte MAC address: XX:XX:XX:XX:XX:XX
    return '${(highInt >> 8) & 0xFF}:${highInt & 0xFF}:${(lowInt >> 24) & 0xFF}:${(lowInt >> 16) & 0xFF}:${(lowInt >> 8) & 0xFF}:${lowInt & 0xFF}';
  }

  String _getSessionEndReason(int code) {
    switch (code) {
      case 1: return 'Target SoC Reached';
      case 2: return 'User Stopped';
      case 3: return 'Fault Occurred';
      case 4: return 'Timeout';
      default: return 'Unknown';
    }
  }
} 
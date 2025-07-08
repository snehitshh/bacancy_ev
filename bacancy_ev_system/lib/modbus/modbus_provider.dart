import 'dart:async';
import 'package:flutter/foundation.dart';
import 'modbus_protocol.dart';
import 'modbus_data_models.dart';

class ModbusProvider extends ChangeNotifier {
  final ModbusProtocol _modbusProtocol = ModbusProtocol();
  
  // Connection state
  ModbusConnectionStatus _connectionStatus = ModbusConnectionStatus.disconnected;
  String _devicePath = '';
  int _baudRate = 9600;
  
  // Data storage
  Map<String, GunInfoData> _gunData = {};
  ACMeterData? _acMeterData;
  DCOutputData? _dcOutputData;
  ChargingSummaryData? _chargingSummaryData;
  FaultData? _faultData;
  SystemStatusData? _systemStatusData;
  
  // Error handling
  ModbusError? _lastError;
  List<ModbusError> _errorHistory = [];
  
  // Stream subscriptions
  StreamSubscription<ModbusData>? _dataSubscription;
  Timer? _pollingTimer;
  
  // Getters
  ModbusConnectionStatus get connectionStatus => _connectionStatus;
  String get devicePath => _devicePath;
  int get baudRate => _baudRate;
  Map<String, GunInfoData> get gunData => _gunData;
  ACMeterData? get acMeterData => _acMeterData;
  DCOutputData? get dcOutputData => _dcOutputData;
  ChargingSummaryData? get chargingSummaryData => _chargingSummaryData;
  FaultData? get faultData => _faultData;
  SystemStatusData? get systemStatusData => _systemStatusData;
  ModbusError? get lastError => _lastError;
  List<ModbusError> get errorHistory => _errorHistory;
  
  // Connection management
  Future<bool> connect(String devicePath, {int baudRate = 9600}) async {
    _devicePath = devicePath;
    _baudRate = baudRate;
    _connectionStatus = ModbusConnectionStatus.connecting;
    notifyListeners();
    
    try {
      final success = await _modbusProtocol.connectToDevice(devicePath, baudRate: baudRate);
      
      if (success) {
        _connectionStatus = ModbusConnectionStatus.connected;
        _setupDataStream();
        _startPolling();
        _clearError();
      } else {
        _connectionStatus = ModbusConnectionStatus.error;
        _setError(ModbusErrorType.connectionFailed, 'Failed to connect to device');
      }
    } catch (e) {
      _connectionStatus = ModbusConnectionStatus.error;
      _setError(ModbusErrorType.connectionFailed, 'Connection error: $e');
    }
    
    notifyListeners();
    return _connectionStatus == ModbusConnectionStatus.connected;
  }
  
  void disconnect() {
    _stopPolling();
    _dataSubscription?.cancel();
    _modbusProtocol.disconnect();
    _connectionStatus = ModbusConnectionStatus.disconnected;
    _clearError();
    notifyListeners();
  }
  
  // Data polling
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_connectionStatus == ModbusConnectionStatus.connected) {
        _pollAllData();
      }
    });
  }
  
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
  
  Future<void> _pollAllData() async {
    try {
      // Poll gun data
      await _pollGunData();
      
      // Poll AC meter data
      await _pollACMeterData();
      
      // Poll DC output data
      await _pollDCOutputData();
      
      // Poll charging summary
      await _pollChargingSummary();
      
      // Poll fault data
      await _pollFaultData();
      
      // Poll system status
      await _pollSystemStatus();
      
      _clearError();
    } catch (e) {
      _setError(ModbusErrorType.timeout, 'Data polling error: $e');
    }
  }
  
  Future<void> _pollGunData() async {
    try {
      final gun1Data = await _modbusProtocol.readGunInfo('Gun 1');
      final gun2Data = await _modbusProtocol.readGunInfo('Gun 2');
      
      _gunData['Gun 1'] = gun1Data;
      _gunData['Gun 2'] = gun2Data;
      
      notifyListeners();
    } catch (e) {
      print('Error polling gun data: $e');
    }
  }
  
  Future<void> _pollACMeterData() async {
    try {
      _acMeterData = await _modbusProtocol.readACMeterInfo();
      notifyListeners();
    } catch (e) {
      print('Error polling AC meter data: $e');
    }
  }
  
  Future<void> _pollDCOutputData() async {
    try {
      _dcOutputData = await _modbusProtocol.readDCOutputInfo();
      notifyListeners();
    } catch (e) {
      print('Error polling DC output data: $e');
    }
  }
  
  Future<void> _pollChargingSummary() async {
    try {
      _chargingSummaryData = await _modbusProtocol.readChargingSummary();
      notifyListeners();
    } catch (e) {
      print('Error polling charging summary: $e');
    }
  }
  
  Future<void> _pollFaultData() async {
    try {
      _faultData = await _modbusProtocol.readFaultInfo();
      notifyListeners();
    } catch (e) {
      print('Error polling fault data: $e');
    }
  }
  
  Future<void> _pollSystemStatus() async {
    try {
      final deviceOnline = await _modbusProtocol.readCoil('device_online');
      final systemStatus = await _modbusProtocol.readRegister('system_status');
      
      _systemStatusData = SystemStatusData(
        deviceOnline: deviceOnline,
        connectionStatus: _connectionStatus.name,
        systemStatus: systemStatus.toInt(),
        lastUpdate: DateTime.now(),
      );
      
      notifyListeners();
    } catch (e) {
      print('Error polling system status: $e');
    }
  }
  
  // Data stream setup
  void _setupDataStream() {
    _dataSubscription?.cancel();
    _dataSubscription = _modbusProtocol.dataStream.listen(
      (data) {
        _handleIncomingData(data);
      },
      onError: (error) {
        _setError(ModbusErrorType.invalidResponse, 'Data stream error: $error');
      },
    );
  }
  
  void _handleIncomingData(ModbusData data) {
    // Handle real-time data updates
    switch (data.functionCode) {
      case ModbusProtocol.READ_HOLDING_REGISTERS:
        _handleRegisterData(data);
        break;
      case ModbusProtocol.READ_COILS:
        _handleCoilData(data);
        break;
    }
  }
  
  void _handleRegisterData(ModbusData data) {
    // Parse register data and update appropriate models
    // This would depend on the specific register addresses
    notifyListeners();
  }
  
  void _handleCoilData(ModbusData data) {
    // Parse coil data and update appropriate models
    notifyListeners();
  }
  
  // Manual data refresh methods
  Future<void> refreshGunData(String gunId) async {
    try {
      final gunData = await _modbusProtocol.readGunInfo(gunId);
      _gunData[gunId] = gunData;
      notifyListeners();
    } catch (e) {
      _setError(ModbusErrorType.dataError, 'Failed to refresh gun data: $e');
    }
  }
  
  Future<void> refreshACMeterData() async {
    try {
      _acMeterData = await _modbusProtocol.readACMeterInfo();
      notifyListeners();
    } catch (e) {
      _setError(ModbusErrorType.dataError, 'Failed to refresh AC meter data: $e');
    }
  }
  
  Future<void> refreshDCOutputData() async {
    try {
      _dcOutputData = await _modbusProtocol.readDCOutputInfo();
      notifyListeners();
    } catch (e) {
      _setError(ModbusErrorType.dataError, 'Failed to refresh DC output data: $e');
    }
  }
  
  Future<void> refreshChargingSummary() async {
    try {
      _chargingSummaryData = await _modbusProtocol.readChargingSummary();
      notifyListeners();
    } catch (e) {
      _setError(ModbusErrorType.dataError, 'Failed to refresh charging summary: $e');
    }
  }
  
  Future<void> refreshFaultData() async {
    try {
      _faultData = await _modbusProtocol.readFaultInfo();
      notifyListeners();
    } catch (e) {
      _setError(ModbusErrorType.dataError, 'Failed to refresh fault data: $e');
    }
  }
  
  // Control methods
  Future<bool> startCharging(String gunId) async {
    try {
      final success = await _modbusProtocol.writeCoil('gun_status', true);
      if (success) {
        await refreshGunData(gunId);
      }
      return success;
    } catch (e) {
      _setError(ModbusErrorType.dataError, 'Failed to start charging: $e');
      return false;
    }
  }
  
  Future<bool> stopCharging(String gunId) async {
    try {
      final success = await _modbusProtocol.writeCoil('gun_status', false);
      if (success) {
        await refreshGunData(gunId);
      }
      return success;
    } catch (e) {
      _setError(ModbusErrorType.dataError, 'Failed to stop charging: $e');
      return false;
    }
  }
  
  Future<bool> setChargingCurrent(String gunId, double current) async {
    try {
      final registerName = gunId == 'Gun 1' ? 'charging_current' : 'charging_current_gun2';
      final success = await _modbusProtocol.writeRegister(registerName, current);
      if (success) {
        await refreshGunData(gunId);
      }
      return success;
    } catch (e) {
      _setError(ModbusErrorType.dataError, 'Failed to set charging current: $e');
      return false;
    }
  }
  
  Future<bool> setChargingVoltage(String gunId, double voltage) async {
    try {
      final registerName = gunId == 'Gun 1' ? 'charging_voltage' : 'charging_voltage_gun2';
      final success = await _modbusProtocol.writeRegister(registerName, voltage);
      if (success) {
        await refreshGunData(gunId);
      }
      return success;
    } catch (e) {
      _setError(ModbusErrorType.dataError, 'Failed to set charging voltage: $e');
      return false;
    }
  }
  
  // Error handling
  void _setError(ModbusErrorType type, String message) {
    _lastError = ModbusError(
      type: type,
      message: message,
      timestamp: DateTime.now(),
    );
    _errorHistory.add(_lastError!);
    
    // Keep only last 10 errors
    if (_errorHistory.length > 10) {
      _errorHistory.removeAt(0);
    }
    
    notifyListeners();
  }
  
  void _clearError() {
    _lastError = null;
    notifyListeners();
  }
  
  void clearErrorHistory() {
    _errorHistory.clear();
    notifyListeners();
  }
  
  // Utility methods
  bool isConnected() {
    return _connectionStatus == ModbusConnectionStatus.connected;
  }
  
  bool hasError() {
    return _lastError != null;
  }
  
  String getConnectionStatusText() {
    switch (_connectionStatus) {
      case ModbusConnectionStatus.disconnected:
        return 'Disconnected';
      case ModbusConnectionStatus.connecting:
        return 'Connecting...';
      case ModbusConnectionStatus.connected:
        return 'Connected';
      case ModbusConnectionStatus.error:
        return 'Error';
    }
  }
  
  // Cleanup
  @override
  void dispose() {
    _stopPolling();
    _dataSubscription?.cancel();
    _modbusProtocol.disconnect();
    super.dispose();
  }
} 
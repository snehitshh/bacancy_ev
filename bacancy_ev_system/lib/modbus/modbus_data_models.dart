import 'dart:typed_data';
import '../queue_models.dart';
import 'package:flutter/material.dart';

// Base Modbus data class
class ModbusData {
  final int functionCode;
  final Uint8List data;
  final DateTime timestamp;

  ModbusData({
    required this.functionCode,
    required this.data,
    required this.timestamp,
  });
}

// Gun Information Data Model
class GunInfoData {
  final String gunId;
  final GunStatus status;
  final double initialSOC;
  final double chargingSOC;
  final double demandVoltage;
  final double chargingCurrent;
  final double demandCurrent;
  final double chargingVoltage;
  final double energyConsumption;
  final double gunTemperature;
  final Duration chargingDuration;

  GunInfoData({
    required this.gunId,
    required this.status,
    required this.initialSOC,
    required this.chargingSOC,
    required this.demandVoltage,
    required this.chargingCurrent,
    required this.demandCurrent,
    required this.chargingVoltage,
    required this.energyConsumption,
    required this.gunTemperature,
    required this.chargingDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'gunId': gunId,
      'status': status.index,
      'initialSOC': initialSOC,
      'chargingSOC': chargingSOC,
      'demandVoltage': demandVoltage,
      'chargingCurrent': chargingCurrent,
      'demandCurrent': demandCurrent,
      'chargingVoltage': chargingVoltage,
      'energyConsumption': energyConsumption,
      'gunTemperature': gunTemperature,
      'chargingDuration': chargingDuration.inSeconds,
    };
  }

  factory GunInfoData.fromJson(Map<String, dynamic> json) {
    return GunInfoData(
      gunId: json['gunId'],
      status: GunStatus.values[json['status']],
      initialSOC: json['initialSOC'].toDouble(),
      chargingSOC: json['chargingSOC'].toDouble(),
      demandVoltage: json['demandVoltage'].toDouble(),
      chargingCurrent: json['chargingCurrent'].toDouble(),
      demandCurrent: json['demandCurrent'].toDouble(),
      chargingVoltage: json['chargingVoltage'].toDouble(),
      energyConsumption: json['energyConsumption'].toDouble(),
      gunTemperature: json['gunTemperature'].toDouble(),
      chargingDuration: Duration(seconds: json['chargingDuration']),
    );
  }
}

// AC Meter Information Data Model
class ACMeterData {
  final double voltageV1N;
  final double voltageV2N;
  final double voltageV3N;
  final double avgVoltageLN;
  final double frequencyHz;
  final double currentI1;
  final double currentI2;
  final double currentI3;
  final double avgCurrent;
  final double activePower;
  final double totalExportEnergy;

  ACMeterData({
    required this.voltageV1N,
    required this.voltageV2N,
    required this.voltageV3N,
    required this.avgVoltageLN,
    required this.frequencyHz,
    required this.currentI1,
    required this.currentI2,
    required this.currentI3,
    required this.avgCurrent,
    required this.activePower,
    required this.totalExportEnergy,
  });

  Map<String, double> toMap() {
    return {
      'Voltage V1N': voltageV1N,
      'Voltage V2N': voltageV2N,
      'Voltage V3N': voltageV3N,
      'Avg Voltage LN': avgVoltageLN,
      'Frequency(Hz)': frequencyHz,
      'Current I1': currentI1,
      'Current I2': currentI2,
      'Current I3': currentI3,
      'Avg Current': avgCurrent,
      'Active Power': activePower,
      'Total Export Energy': totalExportEnergy,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'voltageV1N': voltageV1N,
      'voltageV2N': voltageV2N,
      'voltageV3N': voltageV3N,
      'avgVoltageLN': avgVoltageLN,
      'frequencyHz': frequencyHz,
      'currentI1': currentI1,
      'currentI2': currentI2,
      'currentI3': currentI3,
      'avgCurrent': avgCurrent,
      'activePower': activePower,
      'totalExportEnergy': totalExportEnergy,
    };
  }

  factory ACMeterData.fromJson(Map<String, dynamic> json) {
    return ACMeterData(
      voltageV1N: json['voltageV1N'].toDouble(),
      voltageV2N: json['voltageV2N'].toDouble(),
      voltageV3N: json['voltageV3N'].toDouble(),
      avgVoltageLN: json['avgVoltageLN'].toDouble(),
      frequencyHz: json['frequencyHz'].toDouble(),
      currentI1: json['currentI1'].toDouble(),
      currentI2: json['currentI2'].toDouble(),
      currentI3: json['currentI3'].toDouble(),
      avgCurrent: json['avgCurrent'].toDouble(),
      activePower: json['activePower'].toDouble(),
      totalExportEnergy: json['totalExportEnergy'].toDouble(),
    );
  }
}

// DC Output Information Data Model
class DCOutputData {
  final double voltage;
  final double maxVoltage;
  final double minVoltage;
  final double current;
  final double maxCurrent;
  final double minCurrent;
  final double power;
  final double importEnergy;
  final double exportEnergy;

  DCOutputData({
    required this.voltage,
    required this.maxVoltage,
    required this.minVoltage,
    required this.current,
    required this.maxCurrent,
    required this.minCurrent,
    required this.power,
    required this.importEnergy,
    required this.exportEnergy,
  });

  Map<String, double> toMap() {
    return {
      'Voltage': voltage,
      'Max Voltage': maxVoltage,
      'Min Voltage': minVoltage,
      'Current': current,
      'Max Current': maxCurrent,
      'Min Current': minCurrent,
      'Power': power,
      'Import Energy': importEnergy,
      'Export Energy': exportEnergy,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'voltage': voltage,
      'maxVoltage': maxVoltage,
      'minVoltage': minVoltage,
      'current': current,
      'maxCurrent': maxCurrent,
      'minCurrent': minCurrent,
      'power': power,
      'importEnergy': importEnergy,
      'exportEnergy': exportEnergy,
    };
  }

  factory DCOutputData.fromJson(Map<String, dynamic> json) {
    return DCOutputData(
      voltage: json['voltage'].toDouble(),
      maxVoltage: json['maxVoltage'].toDouble(),
      minVoltage: json['minVoltage'].toDouble(),
      current: json['current'].toDouble(),
      maxCurrent: json['maxCurrent'].toDouble(),
      minCurrent: json['minCurrent'].toDouble(),
      power: json['power'].toDouble(),
      importEnergy: json['importEnergy'].toDouble(),
      exportEnergy: json['exportEnergy'].toDouble(),
    );
  }
}

// Charging Summary Data Model
class ChargingSummaryData {
  final String evMacAddress;
  final Duration chargingDuration;
  final DateTime chargingStartTime;
  final DateTime chargingEndTime;
  final double startSOC;
  final double endSOC;
  final double energyConsumption;
  final String sessionEndReason;
  final double totalCost;

  ChargingSummaryData({
    required this.evMacAddress,
    required this.chargingDuration,
    required this.chargingStartTime,
    required this.chargingEndTime,
    required this.startSOC,
    required this.endSOC,
    required this.energyConsumption,
    required this.sessionEndReason,
    required this.totalCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'EV Mac Address': evMacAddress,
      'Charging Duration': _formatDuration(chargingDuration),
      'Charging Start Date & Time': chargingStartTime.toString(),
      'Charging End Date & Time': chargingEndTime.toString(),
      'Start SoC': startSOC.toString(),
      'End SoC': endSOC.toString(),
      'Energy Consumption': energyConsumption.toString(),
      'Session End Reason': sessionEndReason,
      'Total Cost': totalCost.toString(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'evMacAddress': evMacAddress,
      'chargingDuration': chargingDuration.inSeconds,
      'chargingStartTime': chargingStartTime.millisecondsSinceEpoch,
      'chargingEndTime': chargingEndTime.millisecondsSinceEpoch,
      'startSOC': startSOC,
      'endSOC': endSOC,
      'energyConsumption': energyConsumption,
      'sessionEndReason': sessionEndReason,
      'totalCost': totalCost,
    };
  }

  factory ChargingSummaryData.fromJson(Map<String, dynamic> json) {
    return ChargingSummaryData(
      evMacAddress: json['evMacAddress'],
      chargingDuration: Duration(seconds: json['chargingDuration']),
      chargingStartTime: DateTime.fromMillisecondsSinceEpoch(json['chargingStartTime']),
      chargingEndTime: DateTime.fromMillisecondsSinceEpoch(json['chargingEndTime']),
      startSOC: json['startSOC'].toDouble(),
      endSOC: json['endSOC'].toDouble(),
      energyConsumption: json['energyConsumption'].toDouble(),
      sessionEndReason: json['sessionEndReason'],
      totalCost: json['totalCost'].toDouble(),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}

// Fault Information Data Model
class FaultData {
  final bool plcFaultGun1;
  final bool plcFaultGun2;
  final int rectifierFaults;
  final int communicationErrors;
  final int miscellaneousErrors;

  FaultData({
    required this.plcFaultGun1,
    required this.plcFaultGun2,
    required this.rectifierFaults,
    required this.communicationErrors,
    required this.miscellaneousErrors,
  });

  Map<String, bool> getGunFaultStatus() {
    return {
      'Gun 1': plcFaultGun1,
      'Gun 2': plcFaultGun2,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'plcFaultGun1': plcFaultGun1,
      'plcFaultGun2': plcFaultGun2,
      'rectifierFaults': rectifierFaults,
      'communicationErrors': communicationErrors,
      'miscellaneousErrors': miscellaneousErrors,
    };
  }

  factory FaultData.fromJson(Map<String, dynamic> json) {
    return FaultData(
      plcFaultGun1: json['plcFaultGun1'],
      plcFaultGun2: json['plcFaultGun2'],
      rectifierFaults: json['rectifierFaults'],
      communicationErrors: json['communicationErrors'],
      miscellaneousErrors: json['miscellaneousErrors'],
    );
  }
}

// System Status Data Model
class SystemStatusData {
  final bool deviceOnline;
  final String connectionStatus;
  final int systemStatus;
  final DateTime lastUpdate;

  SystemStatusData({
    required this.deviceOnline,
    required this.connectionStatus,
    required this.systemStatus,
    required this.lastUpdate,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceOnline': deviceOnline,
      'connectionStatus': connectionStatus,
      'systemStatus': systemStatus,
      'lastUpdate': lastUpdate.millisecondsSinceEpoch,
    };
  }

  factory SystemStatusData.fromJson(Map<String, dynamic> json) {
    return SystemStatusData(
      deviceOnline: json['deviceOnline'],
      connectionStatus: json['connectionStatus'],
      systemStatus: json['systemStatus'],
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(json['lastUpdate']),
    );
  }
}

// Modbus Connection Status
enum ModbusConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

// Modbus Error Types
enum ModbusErrorType {
  connectionFailed,
  timeout,
  invalidResponse,
  crcError,
  functionCodeError,
  addressError,
  dataError,
}

// Modbus Error Data
class ModbusError {
  final ModbusErrorType type;
  final String message;
  final DateTime timestamp;

  ModbusError({
    required this.type,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ModbusError.fromJson(Map<String, dynamic> json) {
    return ModbusError(
      type: ModbusErrorType.values[json['type']],
      message: json['message'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }
} 
# Modbus Protocol Implementation for EV System

This directory contains a complete Modbus protocol implementation for the Bacancy EV System, enabling serial communication with EV charging equipment.

## Overview

The Modbus implementation provides:
- **Modbus RTU/TCP Protocol Support**: Full implementation of Modbus protocol for serial communication
- **Real-time Data Polling**: Automatic polling of device data every 2 seconds
- **Comprehensive Data Models**: Structured data models for all EV system parameters
- **Error Handling**: Robust error handling and connection management
- **Provider Pattern**: Flutter Provider integration for state management
- **Android Serial Port Detection**: Native Android serial port discovery and management

## File Structure

```
modbus/
├── modbus_protocol.dart          # Core Modbus protocol implementation
├── modbus_data_models.dart       # Data models for all system parameters
├── modbus_provider.dart          # Provider for state management
├── connection_screen.dart        # UI for connection configuration
├── android_serial_port_finder.dart # Android serial port detection
├── native_serial_port.dart       # Flutter method channel bridge
└── README.md                     # This documentation
```

## Android Serial Port Finder

The implementation includes a comprehensive Android Serial Port Finder that provides:

### Features
- **Native Android Integration**: Direct access to Android serial port drivers
- **Automatic Device Detection**: Scans for available serial devices
- **Driver Information**: Provides detailed driver information for each device
- **Cross-platform Support**: Works on Android, Windows, macOS, and Linux
- **Fallback Mechanism**: Graceful fallback to Dart implementation when native is unavailable

### Implementation Components

#### 1. Native Android Plugin (`SerialPortPlugin.kt`)
- **Kotlin Implementation**: Direct port of the original Java SerialPortFinder
- **Method Channel**: Flutter method channel for communication
- **Driver Detection**: Parses `/proc/tty/drivers` for serial drivers
- **Device Scanning**: Scans `/dev` directory for serial devices

#### 2. Flutter Method Channel (`native_serial_port.dart`)
- **Platform Communication**: Bridges Flutter and native Android code
- **Error Handling**: Comprehensive error handling for platform calls
- **Type Safety**: Type-safe method calls and responses

#### 3. Cross-platform Finder (`android_serial_port_finder.dart`)
- **Platform Detection**: Automatically detects current platform
- **Native Fallback**: Uses native implementation on Android, Dart on other platforms
- **Device Validation**: Validates device paths for different platforms
- **Device Information**: Provides detailed device information and accessibility

### Usage

#### Automatic Device Detection
```dart
// Get all available devices with driver information
final devices = await AndroidSerialPortFinder.getFormattedDeviceList();

// Get device paths only
final devicePaths = await AndroidSerialPortFinder.getAllDevicesPath();

// Check if native functionality is available
final isNativeAvailable = await AndroidSerialPortFinder.isNativeAvailable();
```

#### Device Information
```dart
// Get detailed device information
final deviceInfo = await AndroidSerialPortFinder.getDeviceInfo('/dev/ttyUSB0');

// Check device accessibility
final isAccessible = await AndroidSerialPortFinder.isDeviceAccessible('/dev/ttyUSB0');
```

#### Platform-specific Validation
```dart
// Validate device path for current platform
final isValid = AndroidSerialPortFinder.isValidDevicePath('/dev/ttyUSB0');

// Get platform-specific device prefix
final prefix = AndroidSerialPortFinder.getPlatformDevicePrefix();
```

### Supported Platforms

#### Android
- **Native Implementation**: Direct access to Android serial drivers
- **Device Detection**: Scans `/proc/tty/drivers` and `/dev` directory
- **Driver Information**: Provides driver names and device details
- **Permissions**: Requires appropriate device permissions

#### Windows
- **Common Paths**: COM1-COM10 device paths
- **Device Validation**: Checks for device existence
- **Path Format**: COM-style device naming

#### macOS
- **USB Serial**: `/dev/tty.usbserial-*` patterns
- **USB Modem**: `/dev/tty.usbmodem*` patterns
- **Device Patterns**: Wildcard-based device detection

#### Linux
- **USB Serial**: `/dev/ttyUSB*` devices
- **USB ACM**: `/dev/ttyACM*` devices
- **Serial Ports**: `/dev/ttyS*` devices

## Data Models

### Gun Information Data
- **Gun Status**: Available, Charging, Unavailable
- **SOC Values**: Initial and current State of Charge
- **Electrical Parameters**: Voltage, Current, Power
- **Temperature**: Gun temperature monitoring
- **Duration**: Charging session duration

### AC Meter Information
- **Voltage Readings**: V1N, V2N, V3N, Average Line-to-Neutral
- **Current Readings**: I1, I2, I3, Average Current
- **Power Parameters**: Active Power, Frequency
- **Energy**: Total Export Energy

### DC Output Information
- **Voltage Range**: Current, Maximum, Minimum voltage
- **Current Range**: Current, Maximum, Minimum current
- **Power**: DC Power output
- **Energy**: Import and Export energy values

### Charging Summary
- **Session Details**: EV MAC address, duration, timestamps
- **Battery Status**: Start and End SOC values
- **Energy Consumption**: Session energy usage
- **Cost Information**: Total charging cost

### Fault Information
- **PLC Faults**: Gun-specific fault status
- **Rectifier Faults**: Rectifier system faults
- **Communication Errors**: Communication system errors
- **Miscellaneous Errors**: Other system errors

## Register Address Mapping

The Modbus implementation uses the following register address scheme:

### Gun Information (0x0001 - 0x000F)
- `0x0001`: Gun Status
- `0x0002`: Initial SOC
- `0x0003`: Charging SOC
- `0x0004`: Demand Voltage
- `0x0005`: Charging Current
- `0x0006`: Demand Current
- `0x0007`: Charging Voltage
- `0x0008`: Energy Consumption
- `0x0009`: Gun Temperature
- `0x000A`: Charging Duration (seconds)

### AC Meter Information (0x0100 - 0x010A)
- `0x0100`: Voltage V1N
- `0x0101`: Voltage V2N
- `0x0102`: Voltage V3N
- `0x0103`: Average Voltage LN
- `0x0104`: Frequency (Hz)
- `0x0105`: Current I1
- `0x0106`: Current I2
- `0x0107`: Current I3
- `0x0108`: Average Current
- `0x0109`: Active Power
- `0x010A`: Total Export Energy

### DC Output Information (0x0200 - 0x0208)
- `0x0200`: DC Voltage
- `0x0201`: Max Voltage
- `0x0202`: Min Voltage
- `0x0203`: DC Current
- `0x0204`: Max Current
- `0x0205`: Min Current
- `0x0206`: DC Power
- `0x0207`: Import Energy
- `0x0208`: Export Energy

### Charging Summary (0x0300 - 0x0308)
- `0x0300`: EV MAC Address (High)
- `0x0301`: EV MAC Address (Low)
- `0x0302`: Charging Start Time
- `0x0303`: Charging End Time
- `0x0304`: Start SOC
- `0x0305`: End SOC
- `0x0306`: Session Energy Consumption
- `0x0307`: Session End Reason
- `0x0308`: Total Cost

### Fault Information (0x0400 - 0x0404)
- `0x0400`: PLC Fault Gun 1
- `0x0401`: PLC Fault Gun 2
- `0x0402`: Rectifier Faults
- `0x0403`: Communication Errors
- `0x0404`: Miscellaneous Errors

### System Status (0x0500 - 0x0502)
- `0x0500`: System Status
- `0x0501`: Connection Status
- `0x0502`: Device Online

## Usage

### 1. Setup Provider

Add the ModbusProvider to your app's provider list:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => ModbusProvider()),
    // ... other providers
  ],
  child: MyApp(),
)
```

### 2. Connect to Device

```dart
final modbusProvider = Provider.of<ModbusProvider>(context, listen: false);
await modbusProvider.connect('/dev/ttyUSB0', baudRate: 9600);
```

### 3. Access Data

```dart
Consumer<ModbusProvider>(
  builder: (context, modbusProvider, child) {
    final gunData = modbusProvider.gunData['Gun 1'];
    final acMeterData = modbusProvider.acMeterData;
    final faultData = modbusProvider.faultData;
    
    return YourWidget();
  },
)
```

### 4. Control Operations

```dart
// Start charging
await modbusProvider.startCharging('Gun 1');

// Stop charging
await modbusProvider.stopCharging('Gun 1');

// Set charging parameters
await modbusProvider.setChargingCurrent('Gun 1', 16.0);
await modbusProvider.setChargingVoltage('Gun 1', 400.0);
```

## Connection Configuration

### Supported Baud Rates
- 9600 (default)
- 19200
- 38400
- 57600
- 115200

### Common Device Paths
- **Linux**: `/dev/ttyUSB0`, `/dev/ttyUSB1`, `/dev/ttyACM0`
- **Windows**: `COM1`, `COM2`, `COM3`
- **macOS**: `/dev/tty.usbserial-*`, `/dev/tty.usbmodem*`

### Android Device Detection
The Android implementation automatically detects available serial devices by:
1. Reading `/proc/tty/drivers` to identify serial drivers
2. Scanning `/dev` directory for devices matching driver patterns
3. Providing detailed device information including accessibility

## Error Handling

The implementation includes comprehensive error handling:

### Error Types
- `connectionFailed`: Device connection issues
- `timeout`: Communication timeouts
- `invalidResponse`: Invalid Modbus responses
- `crcError`: CRC validation errors
- `functionCodeError`: Invalid function codes
- `addressError`: Invalid register addresses
- `dataError`: Data parsing errors

### Error Management
```dart
// Check for errors
if (modbusProvider.hasError()) {
  final error = modbusProvider.lastError;
  print('Error: ${error.message}');
}

// Clear error history
modbusProvider.clearErrorHistory();
```

## Data Polling

The system automatically polls device data every 2 seconds when connected:

- **Gun Data**: Both Gun 1 and Gun 2 information
- **AC Meter Data**: Real-time electrical parameters
- **DC Output Data**: DC system parameters
- **Charging Summary**: Session information
- **Fault Data**: System fault status
- **System Status**: Device and connection status

## Manual Data Refresh

You can manually refresh specific data types:

```dart
// Refresh specific data
await modbusProvider.refreshGunData('Gun 1');
await modbusProvider.refreshACMeterData();
await modbusProvider.refreshDCOutputData();
await modbusProvider.refreshChargingSummary();
await modbusProvider.refreshFaultData();
```

## Serial Port Implementation

The implementation uses the `usb_serial` package for serial communication:

```dart
// Connection setup
final port = await UsbSerial.createConnection(devicePath);
await port.setPortParameters(
  baudRate: baudRate,
  dataBits: UsbSerial.DATABITS_8,
  stopBits: UsbSerial.STOPBITS_1,
  parity: UsbSerial.PARITY_NONE,
  setDTR: true,
  setRTS: true,
);
```

## Modbus Protocol Details

### Function Codes Supported
- `0x01`: Read Coils
- `0x02`: Read Discrete Inputs
- `0x03`: Read Holding Registers
- `0x04`: Read Input Registers
- `0x05`: Write Single Coil
- `0x06`: Write Single Register
- `0x0F`: Write Multiple Coils
- `0x10`: Write Multiple Registers

### Data Format
- **Registers**: 16-bit values (scaled by 100 for decimal precision)
- **Coils**: Boolean values (0x0000 = false, 0xFF00 = true)
- **Timestamps**: Unix timestamp in seconds
- **MAC Addresses**: 48-bit values split across two registers

## Integration with UI

The Modbus implementation integrates seamlessly with the existing UI:

1. **Connection Screen**: Configure and manage device connections with automatic device detection
2. **Settings Screen**: Access connection status and configuration
3. **Real-time Updates**: All screens automatically update with live data
4. **Error Display**: User-friendly error messages and status indicators
5. **Device Selection**: Dropdown selection of available devices with detailed information

## Testing

To test the Modbus implementation:

1. Connect a compatible serial device
2. Configure the device path and baud rate (or use automatic detection)
3. Establish connection through the connection screen
4. Monitor real-time data updates
5. Test control operations (start/stop charging)

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check device path and permissions
   - Verify baud rate settings
   - Ensure device is not in use by another application
   - Use automatic device detection to find available devices

2. **Data Not Updating**
   - Check connection status
   - Verify register addresses
   - Monitor error logs

3. **Communication Errors**
   - Check cable connections
   - Verify device compatibility
   - Test with different baud rates

4. **Android Device Detection Issues**
   - Ensure device has appropriate permissions
   - Check if device is rooted (required for some serial access)
   - Verify USB debugging is enabled
   - Check device manufacturer drivers

### Debug Information

Enable debug logging to troubleshoot issues:

```dart
// Add debug prints in modbus_protocol.dart
print('Modbus request: ${request.toList()}');
print('Modbus response: ${response.toList()}');

// Check native serial port availability
final isNativeAvailable = await AndroidSerialPortFinder.isNativeAvailable();
print('Native serial port available: $isNativeAvailable');
```

## Future Enhancements

- **Modbus TCP Support**: Network-based Modbus communication
- **Data Logging**: Persistent data storage and history
- **Advanced Diagnostics**: Detailed communication analysis
- **Configuration Management**: Save and load connection settings
- **Multi-device Support**: Connect to multiple devices simultaneously
- **Enhanced Android Support**: Additional Android-specific serial port features
- **Bluetooth Serial**: Bluetooth serial port support
- **Device Profiles**: Pre-configured device profiles for common hardware 
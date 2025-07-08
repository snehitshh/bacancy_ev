package com.example.bacancy_ev_system

import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileReader
import java.io.IOException
import java.io.LineNumberReader
import java.util.*
import java.io.InputStream

class SerialPortPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val TAG = "SerialPort"

    private var serialPort: android_serialport_api.SerialPort? = null
    private var inputStream: InputStream? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "serial_port")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getAllDevices" -> {
                try {
                    val devices = getAllDevices()
                    result.success(devices)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to get devices", e.message)
                }
            }
            "getAllDevicesPath" -> {
                try {
                    val devicePaths = getAllDevicesPath()
                    result.success(devicePaths)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to get device paths", e.message)
                }
            }
            "isDeviceAccessible" -> {
                val devicePath = call.argument<String>("devicePath")
                if (devicePath != null) {
                    val accessible = isDeviceAccessible(devicePath)
                    result.success(accessible)
                } else {
                    result.error("ERROR", "Device path is required", null)
                }
            }
            "getDeviceInfo" -> {
                val devicePath = call.argument<String>("devicePath")
                if (devicePath != null) {
                    val deviceInfo = getDeviceInfo(devicePath)
                    result.success(deviceInfo)
                } else {
                    result.error("ERROR", "Device path is required", null)
                }
            }
            "openPort" -> {
                val devicePath = call.argument<String>("devicePath")
                val baudrate = call.argument<Int>("baudrate") ?: 9600
                if (devicePath != null) {
                    try {
                        serialPort = android_serialport_api.SerialPort(File(devicePath), baudrate, 0)
                        inputStream = serialPort?.inputStream
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to open port", e.message)
                    }
                } else {
                    result.error("ERROR", "Device path is required", null)
                }
            }
            "readData" -> {
                try {
                    val buffer = ByteArray(256)
                    val size = inputStream?.read(buffer) ?: -1
                    if (size > 0) {
                        val data = buffer.copyOf(size)
                        result.success(data)
                    } else {
                        result.success(null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to read data", e.message)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    inner class Driver(val name: String, val deviceRoot: String) {
        private var devices: Vector<File>? = null

        fun getDevices(): Vector<File> {
            if (devices == null) {
                devices = Vector<File>()
                val dev = File("/dev")
                val files = dev.listFiles()
                if (files != null) {
                    for (file in files) {
                        if (file.absolutePath.startsWith(deviceRoot)) {
                            Log.d(TAG, "Found new device: $file")
                            devices!!.add(file)
                        }
                    }
                }
            }
            return devices ?: Vector()
        }
    }

    private var drivers: Vector<Driver>? = null

    @Throws(IOException::class)
    fun getDrivers(): Vector<Driver> {
        if (drivers == null) {
            drivers = Vector<Driver>()
            val reader = LineNumberReader(FileReader("/proc/tty/drivers"))
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                // Extract driver name (first 21 characters, trimmed)
                val driverName = line!!.substring(0, 0x15).trim()
                val parts = line!!.split(" +".toRegex()).toTypedArray()
                if (parts.size >= 5 && parts[parts.size - 1] == "serial") {
                    Log.d(TAG, "Found new driver $driverName on ${parts[parts.size - 4]}")
                    drivers!!.add(Driver(driverName, parts[parts.size - 4]))
                }
            }
            reader.close()
        }
        return drivers ?: Vector()
    }

    fun getAllDevices(): Array<String> {
        val devices = Vector<String>()
        try {
            val driverIterator = getDrivers().iterator()
            while (driverIterator.hasNext()) {
                val driver = driverIterator.next()
                val deviceIterator = driver.getDevices().iterator()
                while (deviceIterator.hasNext()) {
                    val device = deviceIterator.next()
                    val deviceName = device.name
                    val value = String.format("%s (%s)", deviceName, driver.name)
                    devices.add(value)
                }
            }
        } catch (e: IOException) {
            Log.e(TAG, "Error getting all devices", e)
        }
        return devices.toTypedArray()
    }

    fun getAllDevicesPath(): Array<String> {
        val devices = Vector<String>()
        try {
            val driverIterator = getDrivers().iterator()
            while (driverIterator.hasNext()) {
                val driver = driverIterator.next()
                val deviceIterator = driver.getDevices().iterator()
                while (deviceIterator.hasNext()) {
                    val device = deviceIterator.next()
                    val devicePath = device.absolutePath
                    devices.add(devicePath)
                }
            }
        } catch (e: IOException) {
            Log.e(TAG, "Error getting device paths", e)
        }
        return devices.toTypedArray()
    }

    fun isDeviceAccessible(devicePath: String): Boolean {
        return try {
            val file = File(devicePath)
            file.exists()
        } catch (e: Exception) {
            Log.e(TAG, "Error checking device accessibility", e)
            false
        }
    }

    fun getDeviceInfo(devicePath: String): Map<String, Any>? {
        return try {
            val file = File(devicePath)
            if (!file.exists()) {
                return null
            }

            val info = HashMap<String, Any>()
            info["path"] = devicePath
            info["name"] = file.name
            info["exists"] = true
            info["readable"] = file.canRead()
            info["writable"] = file.canWrite()
            info["size"] = file.length()
            info["modified"] = file.lastModified()
            info["type"] = if (file.isFile) "file" else if (file.isDirectory) "directory" else "other"
            info
        } catch (e: Exception) {
            Log.e(TAG, "Error getting device info for $devicePath", e)
            null
        }
    }
} 
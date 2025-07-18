package com.example.bacancy_ev_system

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the SerialPortPlugin
        flutterEngine.plugins.add(SerialPortPlugin())
    }
}

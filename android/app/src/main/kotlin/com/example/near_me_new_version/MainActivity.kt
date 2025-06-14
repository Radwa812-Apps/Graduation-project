package com.example.near_me_new_version

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.near_me_new_version/floating_button"
    private val ALERT_CHANNEL = "com.example.near_me_new_version/alert"
    private var isServiceRunning = false
    private val TAG = "MainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate called")

        intent?.let { handleIntent(it) }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            Log.d(TAG, "Requesting overlay permission")
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, 1234)
            Toast.makeText(
                this,
                "Please enable 'Draw over other apps' permission to show the floating button.",
                Toast.LENGTH_LONG
            ).show()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d(TAG, "onNewIntent called")
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        if (intent.getBooleanExtra("alertSent", false)) {
            val groupIds = intent.getStringArrayListExtra("groupIds") ?: emptyList()
            Log.d(TAG, "Received alertSent with groupIds: $groupIds")
            sendAlertNotification(groupIds)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "Configuring Flutter engine")

        val alertChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger!!, ALERT_CHANNEL)
        alertChannel.setMethodCallHandler { call, result ->
            Log.d(TAG, "Alert channel method call received: ${call.method}")
            result.success(null)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger!!, CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "Method call received: ${call.method}")
            when (call.method) {
                "toggleFloatingButton" -> {
                    val enable = call.argument<Boolean>("enable") ?: false
                    Log.d(TAG, "toggleFloatingButton called with enable: $enable")
                    if (enable && !isServiceRunning) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                            result.error("PERMISSION_DENIED", "Overlay permission not granted", null)
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            )
                            startActivity(intent)
                        } else {
                            val intent = Intent(this, FloatingButtonService::class.java)
                            intent.putExtra("enable", true)
                            startService(intent)
                            isServiceRunning = true
                            result.success("Floating button started")
                            Log.d(TAG, "Floating button service started")
                        }
                    } else if (!enable && isServiceRunning) {
                        val intent = Intent(this, FloatingButtonService::class.java)
                        stopService(intent)
                        isServiceRunning = false
                        result.success("Floating button stopped")
                        Log.d(TAG, "Floating button service stopped")
                    } else {
                        result.success(if (isServiceRunning) "Floating button is running" else "Floating button is stopped")
                        Log.d(TAG, "Service state: ${if (isServiceRunning) "running" else "stopped"}")
                    }
                }
                else -> {
                    result.notImplemented()
                    Log.d(TAG, "Method not implemented: ${call.method}")
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.d(TAG, "onActivityResult called with requestCode: $requestCode")
        if (requestCode == 1234) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Settings.canDrawOverlays(this)) {
                val intent = Intent(this, FloatingButtonService::class.java)
                intent.putExtra("enable", true)
                startService(intent)
                isServiceRunning = true
                Toast.makeText(this, "Floating button service started", Toast.LENGTH_SHORT).show()
                Log.d(TAG, "Overlay permission granted, service started")
            } else {
                Toast.makeText(this, "Permission denied, floating button won't work.", Toast.LENGTH_LONG).show()
                Log.e(TAG, "Overlay permission denied")
            }
        }
    }

    private fun sendAlertNotification(groupIds: List<String>) {
        flutterEngine?.dartExecutor?.binaryMessenger?.let { binaryMessenger ->
            val alertChannel = MethodChannel(binaryMessenger, ALERT_CHANNEL)
            alertChannel.invokeMethod("alertSent", mapOf("groupIds" to groupIds), object : MethodChannel.Result {
                override fun success(result: Any?) {
                    Log.d(TAG, "Alert notification sent successfully to Flutter")
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.e(TAG, "Error sending alert notification: $errorMessage")
                }

                override fun notImplemented() {
                    Log.e(TAG, "Alert notification method not implemented")
                }
            })
        } ?: Log.e(TAG, "Flutter engine or binary messenger is null")
    }
}

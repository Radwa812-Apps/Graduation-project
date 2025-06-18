package com.example.near_me_new_version

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.*
import android.widget.Button
import android.widget.Toast
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import java.util.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class FloatingButtonService : Service() {
    private lateinit var windowManager: WindowManager
    private lateinit var floatingButton: View
    private val firestore = FirebaseFirestore.getInstance()
    private val auth = FirebaseAuth.getInstance()
    private val TAG = "FloatingButtonService"
    private var isButtonVisible = false
    private var methodChannel: MethodChannel? = null


    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service onCreate called")
        setupFloatingButton()
    }

    private fun setupFloatingButton() {
        if (isButtonVisible) {
        Log.d(TAG, "Floating button already visible, skipping setup")
        return
        }
        val flutterEngine = FlutterEngineCache.getInstance().get("my_engine_id")
if (flutterEngine != null) {
    methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.near_me_new_version/floating_button")
}

        Log.d(TAG, "setupFloatingButton called")
        floatingButton = LayoutInflater.from(this).inflate(R.layout.floating_button_layout, null)
        Log.d(TAG, "Inflated floating button layout: ${floatingButton != null}")

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 100
            y = 300
            Log.d(TAG, "LayoutParams created: type=${this.type}, flags=${this.flags}")
        }

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        Log.d(TAG, "WindowManager initialized: $windowManager")

        try {
            windowManager.addView(floatingButton, params)
            Log.d(TAG, "Floating button added to window successfully")
            isButtonVisible = true
        } catch (e: Exception) {
            Log.e(TAG, "Error adding floating button: ${e.message}", e)
        }

        // ✅ السحب والتحريك
        floatingButton.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f

            override fun onTouch(v: View?, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params.x
                        initialY = params.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params.x = initialX + (event.rawX - initialTouchX).toInt()
                        params.y = initialY + (event.rawY - initialTouchY).toInt()
                        windowManager.updateViewLayout(floatingButton, params)
                        return true
                    }
                }
                return false
            }
        })

        // ✅ الضغط على الزر يرسل التنبيهات
        floatingButton.findViewById<Button>(R.id.floating_button)?.setOnClickListener {
            Log.d(TAG, "Floating button clicked")
            methodChannel?.invokeMethod("onFloatingButtonPressed", null)
            
            sendAlertToSelectedGroups()
        } ?: Log.e(TAG, "Floating button view not found with ID: R.id.floating_button")
    }

    private fun sendAlertToSelectedGroups() {
        val user = auth.currentUser ?: run {
            showToast("Please sign in first")
            Log.e(TAG, "No authenticated user")
            return
        }

        Log.d(TAG, "Starting alert process for user: ${user.uid}")

        firestore.collection("selected_alert_groups")
            .document(user.uid)
            .get()
            .addOnSuccessListener { document ->
                Log.d(TAG, "Document fetched: ${document.exists()}")
                if (!document.exists()) {
                    showToast("No valid groups found")
                    Log.e(TAG, "Document does not exist for user: ${user.uid}")
                    return@addOnSuccessListener
                }

                val groupIds = document.get("groups") as? List<String>
                Log.d(TAG, "Retrieved groupIds: $groupIds")
                if (groupIds == null || groupIds.isEmpty()) {
                    showToast("No groups selected")
                    Log.e(TAG, "groupIds field is missing or empty for user: ${user.uid}")
                    return@addOnSuccessListener
                }

                Log.d(TAG, "Found ${groupIds.size} groups to alert: $groupIds")
                sendAlertsToGroups(groupIds)
            }
            .addOnFailureListener { e ->
                showToast("Failed to load groups")
                Log.e(TAG, "Error loading groups for user: ${user.uid}, Error: ${e.message}", e)
            }
    }

    private fun sendAlertsToGroups(groupIds: List<String>) {
        Log.d(TAG, "sendAlertsToGroups called with ${groupIds.size} groups")
        val batch = firestore.batch()
        val timestamp = Date()
        val userId = auth.currentUser?.uid ?: ""

        groupIds.forEach { groupId ->
            val groupRef = firestore.collection("groups").document(groupId)
            Log.d(TAG, "Updating group: $groupId")
            batch.update(groupRef, mapOf(
                "alert" to true,
                "alert_timestamp" to timestamp,
                "alert_color" to "#FF0000",
                "last_alert_sender" to userId
            ))
        }

        val alertRef = firestore.collection("group_risk_alerts").document()
        Log.d(TAG, "Setting alertRef: $alertRef")
        batch.set(alertRef, mapOf(
            "groupIds" to groupIds,
            "userId" to userId,
            "timestamp" to timestamp,
            "status" to "active"
        ))

        batch.commit()
            .addOnSuccessListener {
                showToast("Alerts sent successfully to ${groupIds.size} groups")
                Log.d(TAG, "Batch commit successful for groups: $groupIds")

                val intent = Intent(this, MainActivity::class.java)
                intent.putExtra("alertSent", true)
                intent.putStringArrayListExtra("groupIds", ArrayList(groupIds))
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                startActivity(intent)
            }
            .addOnFailureListener { e ->
                showToast("Failed to send alerts")
                Log.e(TAG, "Batch commit failed for groups: $groupIds, Error: ${e.message}", e)
            }
    }

    private fun showToast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::floatingButton.isInitialized) {
            try {
                windowManager.removeView(floatingButton)
                Log.d(TAG, "Floating button removed from window")
                isButtonVisible = false
            } catch (e: Exception) {
                Log.e(TAG, "Error removing floating button: ${e.message}", e)
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand called with intent: $intent")
        val shouldEnable = intent?.getBooleanExtra("enable", false) ?: false
        if (!shouldEnable) {
            Log.w(TAG, "Service started without enable = true, stopping...")
            stopSelf()
            return START_NOT_STICKY
        }

        setupFloatingButton()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
package com.example.near_me_new_version
import kotlin.math.abs
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.*
import android.widget.Button
import com.google.firebase.firestore.SetOptions
import android.widget.Toast
import com.google.firebase.auth.FirebaseAuth
import java.util.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper
import com.google.firebase.FirebaseApp
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreSettings
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
        // if (FirebaseApp.getApps(this).isEmpty()) {
        //  FirebaseApp.initializeApp(this)
        //  Log.d(TAG, "FirebaseApp initialized manually")
        // }
        // val firestore = FirebaseFirestore.getInstance()
        // val settings = FirebaseFirestoreSettings.Builder()
        //     .setPersistenceEnabled(true)
        //     .build()
        //firestore.firestoreSettings = settings

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
        floatingButton.findViewById<Button>(R.id.floating_button)?.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f
            private val clickThreshold = 5  
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
                val deltaX = event.rawX - initialTouchX
                val deltaY = event.rawY - initialTouchY

                
                params.x = initialX + deltaX.toInt()
                params.y = initialY + deltaY.toInt()
                windowManager.updateViewLayout(floatingButton, params)
                return true
            }

            MotionEvent.ACTION_UP -> {
                val deltaX = (event.rawX - initialTouchX).toInt()
                val deltaY = (event.rawY - initialTouchY).toInt()

                if (abs(deltaX) < clickThreshold && abs(deltaY) < clickThreshold) {
                    
                    v?.performClick()
                }
                return true
            }
        }
        return false
        }
        })


        // ✅ الضغط على الزر يرسل التنبيهات
        floatingButton.findViewById<Button>(R.id.floating_button)?.setOnClickListener {
            Log.d(TAG, "Floating button clicked")
            // if (FirebaseApp.getApps(this).isEmpty()) {
            // FirebaseApp.initializeApp(this)
            // Log.d(TAG, "FirebaseApp initialized manually")
            // }
            // val firestore = FirebaseFirestore.getInstance()
            // val settings = FirebaseFirestoreSettings.Builder()
            //     .setPersistenceEnabled(true)
            //     .build()
            // firestore.firestoreSettings = settings
            showEmergencyConfirmationDialog()

        } ?: Log.e(TAG, "Floating button view not found with ID: R.id.floating_button")
    }
    private fun showEmergencyConfirmationDialog() {
        val inflater = LayoutInflater.from(this)
        val dialogView = inflater.inflate(R.layout.overlay_confirmation_dialog, null)

        val yesButton = dialogView.findViewById<Button>(R.id.btn_yes)
        val noButton = dialogView.findViewById<Button>(R.id.btn_no)

        val params = WindowManager.LayoutParams(
        600,  
        WindowManager.LayoutParams.WRAP_CONTENT,
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            WindowManager.LayoutParams.TYPE_PHONE,
        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
        PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }

        val windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        windowManager.addView(dialogView, params)

        val handler = Handler(Looper.getMainLooper())
        val timeoutRunnable = Runnable {
            // No response within 2 minute
            windowManager.removeView(dialogView)
            //sendHelpRequest() // automatically
            methodChannel?.invokeMethod("onFloatingButtonPressed", null)
            
            sendAlertToSelectedGroups()
        }

        // Start timeout
        handler.postDelayed(timeoutRunnable, 120000)

        yesButton.setOnClickListener {
            handler.removeCallbacks(timeoutRunnable)
            windowManager.removeView(dialogView)
            //sendHelpRequest() // 
            methodChannel?.invokeMethod("onFloatingButtonPressed", null)
            
            sendAlertToSelectedGroups()
        }

        noButton.setOnClickListener {
            handler.removeCallbacks(timeoutRunnable)
            windowManager.removeView(dialogView)
            //  Cancelled
        }
    }

    private fun sendAlertToSelectedGroups() {
        val user = auth.currentUser ?: run {
            showToast("Please sign in first")
            Log.e(TAG, "No authenticated user")
            return
        }

        Log.d(TAG, "Starting alert process for user: ${user.uid}")
        try{
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
        }catch (e: IllegalStateException) {
            Log.e(TAG, "Firestore client already terminated: ${e.message}")
        }
    }
    
    private fun sendAlertsToGroups(groupIds: List<String>) {    
        if (groupIds.isEmpty()) {
            Log.w(TAG, "No group IDs provided")
            return
        }
    val userId = auth.currentUser?.uid ?: run {
        Log.e(TAG, "User not authenticated")
        showToast("User not authenticated")
        return
    }
    val flutterEngine = FlutterEngineCache.getInstance().get("my_engine_id")
        if (flutterEngine != null) {
            methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.near_me_new_version/floating_button")
        }
    val params = mapOf(
        "groups" to groupIds,
        "userId" to userId
    )
    methodChannel?.invokeMethod("sendAlertToSelectedGroups", params, object : MethodChannel.Result {
        override fun success(result: Any?) {
            Log.d(TAG, "Alerts sent successfully")
        }
        
        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            Log.e(TAG, "Failed to send alerts: $errorMessage")
        }
        
        override fun notImplemented() {
            Log.e(TAG, "Method not implemented")
        }
    })     
    

    val timestamp = Date()

    // لكل مجموعة، نجلب الأعضاء أولاً ثم ننشئ Batch جديد
    groupIds.forEach { groupId ->
        val groupRef = firestore.collection("groups").document(groupId)
        
        groupRef.get().addOnSuccessListener { document ->
            if (document.exists()) {
                val members = document.get("members") as? List<String> ?: emptyList()
                
                // إنشاء Batch جديد لكل مجموعة
                val batch = firestore.batch()
                
                // 1. تحديث بيانات المجموعة الرئيسية
                batch.update(groupRef, mapOf(
                    "alert" to true,
                    "alert_timestamp" to timestamp,
                    "alert_color" to "#FF0000",
                    "last_alert_sender" to userId,
                    "alert_triggered" to true
                ))

                // 2. إضافة تنبيهات لكل عضو
                members.forEach { memberId ->
                    val memberAlertRef = groupRef.collection("group_alerts").document(memberId)
                    batch.set(memberAlertRef, mapOf(
                        "alert" to true,
                        "alert_timestamp" to timestamp,
                        "alert_color" to "#FF0000",
                        "last_alert_sender" to userId,
                        "alert_triggered" to true
                    ), SetOptions.merge())
                }

                // 3. إضافة التنبيه العام (إذا لزم الأمر)
                val alertRef = firestore.collection("group_risk_alerts").document()
                batch.set(alertRef, mapOf(
                    "groupIds" to listOf(groupId), // نرسل مجموعة واحدة فقط هنا
                    "userId" to userId,
                    "timestamp" to timestamp,
                    "status" to "active"
                ))

                // تنفيذ الباتش
                batch.commit()
                    .addOnSuccessListener {
                        Log.d(TAG, "Alerts sent for group $groupId")
                        showToast("alert sent successfuly to $groupId")
                    }
                    .addOnFailureListener { e ->
                        Log.e(TAG, "Failed to send alerts for group $groupId", e)
                        showToast("failed to send alert to $groupId")
                    }
            } else {
                Log.e(TAG, "Group $groupId does not exist")
            }
        }.addOnFailureListener { e ->
            Log.e(TAG, "Error fetching group $groupId members", e)
        }
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
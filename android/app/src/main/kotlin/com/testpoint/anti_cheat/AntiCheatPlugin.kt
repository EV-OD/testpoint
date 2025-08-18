package com.testpoint.anti_cheat

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.AppOpsManager
import android.provider.Settings
import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

class AntiCheatPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null
    private var isScreenPinned = false
    private var isMonitoring = false
    private var lastAppSwitchTime = 0L
    private var monitoringExecutor: ScheduledExecutorService? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        private const val CHANNEL = "testpoint/anti_cheat"
        private const val MONITORING_INTERVAL = 1000L // 1 second
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "enableScreenPinning" -> enableScreenPinning(result)
            "disableScreenPinning" -> disableScreenPinning(result)
            "enableScreenshotPrevention" -> enableScreenshotPrevention(result)
            "disableScreenshotPrevention" -> disableScreenshotPrevention(result)
            "enableScreenRecordingDetection" -> enableScreenRecordingDetection(result)
            "disableScreenRecordingDetection" -> disableScreenRecordingDetection(result)
            "startAppLifecycleMonitoring" -> startAppLifecycleMonitoring(result)
            "stopAppLifecycleMonitoring" -> stopAppLifecycleMonitoring(result)
            else -> result.notImplemented()
        }
    }

    private fun enableScreenPinning(result: Result) {
        activity?.let { act ->
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    act.startLockTask()
                    isScreenPinned = true
                    result.success(true)
                } else {
                    result.success(false)
                }
            } catch (e: Exception) {
                result.success(false)
            }
        } ?: result.success(false)
    }

    private fun disableScreenPinning(result: Result) {
        activity?.let { act ->
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && isScreenPinned) {
                    act.stopLockTask()
                    isScreenPinned = false
                }
                result.success(true)
            } catch (e: Exception) {
                result.success(false)
            }
        } ?: result.success(true)
    }

    private fun enableScreenshotPrevention(result: Result) {
        activity?.let { act ->
            try {
                act.window.setFlags(
                    WindowManager.LayoutParams.FLAG_SECURE,
                    WindowManager.LayoutParams.FLAG_SECURE
                )
                result.success(true)
            } catch (e: Exception) {
                result.success(false)
            }
        } ?: result.success(false)
    }

    private fun disableScreenshotPrevention(result: Result) {
        activity?.let { act ->
            try {
                act.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                result.success(true)
            } catch (e: Exception) {
                result.success(false)
            }
        } ?: result.success(true)
    }

    private fun enableScreenRecordingDetection(result: Result) {
        // Screen recording detection is complex on Android
        // For now, we'll use the screenshot prevention as a basic measure
        enableScreenshotPrevention(result)
    }

    private fun disableScreenRecordingDetection(result: Result) {
        disableScreenshotPrevention(result)
    }

    private fun startAppLifecycleMonitoring(result: Result) {
        if (isMonitoring) {
            result.success(true)
            return
        }

        context?.let { ctx ->
            isMonitoring = true
            monitoringExecutor = Executors.newSingleThreadScheduledExecutor()
            
            monitoringExecutor?.scheduleAtFixedRate({
                checkAppInForeground(ctx)
            }, 0, MONITORING_INTERVAL, TimeUnit.MILLISECONDS)
            
            result.success(true)
        } ?: result.success(false)
    }

    private fun stopAppLifecycleMonitoring(result: Result) {
        isMonitoring = false
        monitoringExecutor?.shutdown()
        monitoringExecutor = null
        result.success(true)
    }

    private fun checkAppInForeground(context: Context) {
        try {
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val packageName = context.packageName
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val appTasks = activityManager.appTasks
                var isInForeground = false
                
                for (task in appTasks) {
                    val taskInfo = task.taskInfo
                    if (taskInfo.baseActivity?.packageName == packageName) {
                        isInForeground = true
                        break
                    }
                }
                
                if (!isInForeground && isMonitoring) {
                    handleAppSwitch()
                }
            } else {
                // For older Android versions, use different approach
                val runningTasks = activityManager.getRunningTasks(1)
                if (runningTasks.isNotEmpty()) {
                    val topActivity = runningTasks[0].topActivity
                    if (topActivity?.packageName != packageName && isMonitoring) {
                        handleAppSwitch()
                    }
                }
            }
        } catch (e: Exception) {
            // Handle security exceptions or other errors
        }
    }

    private fun handleAppSwitch() {
        val currentTime = System.currentTimeMillis()
        val duration = if (lastAppSwitchTime > 0) currentTime - lastAppSwitchTime else 0L
        lastAppSwitchTime = currentTime
        
        mainHandler.post {
            val arguments = mapOf(
                "appName" to "Unknown App",
                "duration" to duration.toInt()
            )
            channel.invokeMethod("onAppSwitch", arguments)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        stopAppLifecycleMonitoring(object : Result {
            override fun success(result: Any?) {}
            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
            override fun notImplemented() {}
        })
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        // Ensure screen pinning is disabled when detaching
        if (isScreenPinned) {
            disableScreenPinning(object : Result {
                override fun success(result: Any?) {}
                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
                override fun notImplemented() {}
            })
        }
        activity = null
    }
}

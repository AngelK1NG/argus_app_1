package technology.focal.focal

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.hardware.display.DisplayManager
import android.view.Display
import android.os.PowerManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "plugins.flutter.io/screen"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        call, result ->
            if (call.method == "isScreenOn") {
                result.success(isScreenOn())
            } else {
                result.notImplemented()
            }
        }
    }
    /**
     * Is the screen of the device on.
     * @param context the context
     * @return true when (at least one) screen is on
     */
    private fun isScreenOn(): Boolean {
        return if (VERSION.SDK_INT >= VERSION_CODES.KITKAT_WATCH) {
            val dm: DisplayManager = getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
            var screenOn = false
            for (display in dm.getDisplays()) {
                if (display.getState() != Display.STATE_OFF) {
                    screenOn = true
                }
            }
            screenOn
        } else {
            val pm: PowerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            pm.isScreenOn()
        }
    }
}
package com.ammar.cafeteria

import com.google.firebase.installations.FirebaseInstallations
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "firebase_installations"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "deleteInstallationId") {
                FirebaseInstallations.getInstance().delete().addOnCompleteListener { task ->
                    if (task.isSuccessful) {
                        result.success(true)
                    } else {
                        result.error("DELETE_FAILED", task.exception?.message, null)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

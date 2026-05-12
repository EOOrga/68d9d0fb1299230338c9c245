package com.taziggg100.bonnierops

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun getInitialRoute(): String? {
        return intent.getStringExtra("route") ?: super.getInitialRoute()
    }
}

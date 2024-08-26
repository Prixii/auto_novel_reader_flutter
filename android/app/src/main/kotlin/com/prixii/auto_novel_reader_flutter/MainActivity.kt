package com.prixii.auto_novel_reader_flutter

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler

class MainActivity : FlutterActivity() {
    private var volumeKeyShiftEnabled = true
    private var eventSink: EventChannel.EventSink? = null
    private val eventChannel: EventChannel by lazy {
        EventChannel(flutterEngine!!.dartExecutor.binaryMessenger, "auto_novel_reader_flutter/key_event_channel")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // TODO 主动初始化 android EventChannel
        eventChannel.setStreamHandler(
            object : StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink,
                ) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            },
        )
    }


    override fun onKeyDown(
        keyCode: Int,
        event: KeyEvent?,
    ): Boolean {
        if (volumeKeyShiftEnabled) {
            when (keyCode) {
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    eventSink?.success("volumeDown")
                    return true
                }
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    eventSink?.success("volumeUp")
                    return true
                }
            }
        }
        return super.onKeyDown(keyCode, event)
    }
}

package com.prixii.auto_novel_reader_flutter

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var volumeKeyShiftEnabled = false
    private var eventSink: EventChannel.EventSink? = null
    private val eventChannel: EventChannel by lazy {
        EventChannel(flutterEngine!!.dartExecutor.binaryMessenger, "auto_novel_reader_flutter/key_event_channel")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // TODO 在需要的时候建立
        initEventChannel()
        initMethodChannel()
    }

    private fun initEventChannel() {
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

    private fun initMethodChannel() {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "auto_novel_reader_flutter/method_channel")
            .setMethodCallHandler {
                    call, result ->
                println("call method ")
                when (call.method) {
                    "enableVolumeKeyShift" -> {
                        enableVolumeKeyShift()
                        println("enable")
                        result.success(true)
                    }

                    "disableVolumeKeyShift" -> {
                        disableVolumeKeyShift()
                        println("disable")
                        result.success(true)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
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

    private fun disableVolumeKeyShift() {
        volumeKeyShiftEnabled = false
    }

    private fun enableVolumeKeyShift() {
        volumeKeyShiftEnabled = true
    }
}

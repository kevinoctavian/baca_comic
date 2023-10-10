package com.vinindie.apps.baca_komik

import android.content.Context
import android.os.Environment
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
	private val CHANNEL = "com.vinindie.apps.baca_komik";
	
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			if (call.method == "getPictureDirectoryPath") {
				val pictureDir = getPictureDirectory()
				result.success(pictureDir)
			} else if (call.method == "getDocumentDirectoryPath") {
				val pictureDir = getDocumentDirectory()
				result.success(pictureDir)
			} 			
			else {
				result.notImplemented()
			}
		}
	}

	private fun getPictureDirectory(): String {
		val pictureDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
		return pictureDir.absolutePath
	}

	private fun getDocumentDirectory(): String {
		val pictureDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
		return pictureDir.absolutePath
	}
}

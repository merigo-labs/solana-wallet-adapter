/// Package
/// ------------------------------------------------------------------------------------------------

package com.merigo.solana_wallet_adapter


/// Imports
/// ------------------------------------------------------------------------------------------------

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.*
import kotlinx.coroutines.channels.actor
import kotlin.coroutines.CoroutineContext


/// Solana Wallet Adapter Plugin
/// ------------------------------------------------------------------------------------------------

class SolanaWalletAdapterPlugin:
  FlutterPlugin,
  MethodCallHandler,
  ActivityAware,
  PluginRegistry.ActivityResultListener {

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  /// View context and scope.
  private var parentJob = Job()
  private val coroutineContext: CoroutineContext get() = parentJob + Dispatchers.Main
  private val viewModelScope = CoroutineScope(coroutineContext)

  /// Main view activity.
  private var activity: Activity? = null

  ///
  private var cancelLocalAssociation: (() -> Unit)? = null

  private var intentData: Uri? = null

  /// Constants
  companion object {
    private val TAG = javaClass.simpleName
    private const val METHOD_CHANNEL_NAME = "solana_wallet_adapter"
    private const val WALLET_ACTIVITY_REQUEST_CODE = 1234
  }

  /// Incoming (Flutter -> Android) method channel method names.
  enum class IncomingMethod(val value: String) {
    OPEN_STORE("openStore"),
    OPEN_WALLET("openWallet"),
    CLOSE_WALLET("closeWallet"),
  }

  /// Outgoing (Android -> Flutter) method channel method names.
  enum class OutgoingMethod(val value: String) {
    WALLET_CLOSED("walletClosed"),
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when(call.method) {
      IncomingMethod.OPEN_STORE.value
      -> viewModelScope.launch { openStore(call, result) }
      IncomingMethod.OPEN_WALLET.value
      -> viewModelScope.launch { openWallet(call, result) }
      IncomingMethod.CLOSE_WALLET.value
      -> viewModelScope.launch { closeWallet(call, result) }
      else
      -> result.notImplemented()
    }
  }

  private fun openStore(
    @NonNull call: MethodCall,
    @NonNull result: Result,
  ) {
    val id = call.argument<String>("id")
    startPlayStoreIntent("https://play.google.com/store/apps/details?id=$id")
//    try {
//      startPlayStoreIntent("market://details?id=$id")
//    } catch (e: ActivityNotFoundException) {
//      startPlayStoreIntent("https://play.google.com/store/apps/details?id=$id")
//    }
    result.success(true)
  }

  private suspend fun openWallet(
    @NonNull call: MethodCall,
    @NonNull result: Result,
  ) = coroutineScope {
    var opened = try {
      val uri = call.argument<String>("uri")?.let { Uri.parse(it) }

      val associationIntent = Intent()
        .setAction(Intent.ACTION_VIEW)
        .addCategory(Intent.CATEGORY_BROWSABLE)
        .setData(uri)

      startLocalAssociationIntent(associationIntent) {
        Log.d(TAG, "INTENT LOADED ${activity?.isTaskRoot}")
        this@coroutineScope.cancel()
      }

      true
    } catch (e: Throwable) {
      activity?.finishActivity(WALLET_ACTIVITY_REQUEST_CODE)
      false
    }
    result.success(opened)
  }

  private suspend fun closeWallet(
    @NonNull call: MethodCall,
    @NonNull result: Result,
  ) = coroutineScope {
    var closed = try {
      activity?.finishActivity(WALLET_ACTIVITY_REQUEST_CODE)
      true
    } catch (e: Throwable) {
      false
    }
    result.success(closed)
  }

  private fun startPlayStoreIntent(
    uriString: String,
  ) {
    activity?.let {
      it.startActivity(
        Intent(
          Intent.ACTION_VIEW,
          Uri.parse(uriString)
        )
      )
    }
  }

  private fun startLocalAssociationIntent(
    intent: Intent,
    cancelLocalAssociationCallback: () -> Unit
  ) {
    synchronized(this) {
      check(cancelLocalAssociation == null)
      cancelLocalAssociation = cancelLocalAssociationCallback
    }
    activity?.let {
      intentData = intent.data
      it.startActivityForResult(intent, WALLET_ACTIVITY_REQUEST_CODE)
    }
  }

  private fun completeLocalAssociationIntent(code: Int, intent: Intent?): Boolean {
    return synchronized(this) {
      cancelLocalAssociation?.let {
        viewModelScope.launch { it() }
        channel.invokeMethod(
          OutgoingMethod.WALLET_CLOSED.value,
          mapOf("uri" to (intent?.data ?: intentData)?.toString())
        );
      }
      cancelLocalAssociation = null
      true
    }
  }

  private fun setActivity(binding: ActivityPluginBinding?) {
    activity = binding?.activity
    cancelLocalAssociation = null
    binding?.let { it.addActivityResultListener(this) }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    setActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    setActivity(null)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    setActivity(binding)
  }

  override fun onDetachedFromActivity() {
    setActivity(null)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    Log.d(TAG, "Req Code $requestCode, Res Code $resultCode, Cancel Code ${Activity.RESULT_CANCELED}")
    return when(requestCode) {
      WALLET_ACTIVITY_REQUEST_CODE -> completeLocalAssociationIntent(requestCode, data)
      else -> false
    }
  }
}

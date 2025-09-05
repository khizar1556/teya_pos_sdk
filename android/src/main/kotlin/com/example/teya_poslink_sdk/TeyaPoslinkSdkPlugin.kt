package com.example.teya_poslink_sdk

import android.app.Activity
import android.content.Context
import android.util.Log
import com.teya.unifiedepossdk.UnifiedEposSDK
import com.teya.unifiedepossdk.UnifiedEposIntegration
import com.teya.unifiedepossdk.PaymentStateSubscription
import com.teya.unifiedepossdk.poslink.PosLinkSetup
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

class TeyaPoslinkSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler {
    private lateinit var channel: MethodChannel
    private lateinit var paymentStateChannel: EventChannel
    private var context: Context? = null
    private var activity: Activity? = null

    private var teyaPosLinkSDK: PosLinkSetup? = null
    private var teyaPosLinkIntegration: UnifiedEposIntegration? = null
    private var currentPaymentSubscription: PaymentStateSubscription? = null
    private var paymentStateEventSink: EventChannel.EventSink? = null
    
    private val paymentStateListeners = ConcurrentHashMap<String, PaymentStateSubscription.PaymentStateChangeListener>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "teya_poslink_sdk")
        channel.setMethodCallHandler(this)
        
        paymentStateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "teya_poslink_sdk/payment_state")
        paymentStateChannel.setStreamHandler(this)
        
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initialize(call, result)
            "setupPosLink" -> setupPosLink(result)
            "makePayment" -> makePayment(call, result)
            "cancelPayment" -> cancelPayment(result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(call: MethodCall, result: Result) {
        try {
            val config = call.arguments as Map<String, Any>
            
            teyaPosLinkSDK = UnifiedEposSDK(logger = FlutterLogger())
                .posLink(
                    PosLinkSetup.ApisConfig(
                        teyaIdHostUrl = config["teyaIdHostUrl"] as String,
                        teyaApiHostUrl = config["teyaApiHostUrl"] as String,
                        clientId = config["clientId"] as String,
                        clientSecret = config["clientSecret"] as String,
                    )
                )

            result.success(null)
        } catch (e: Exception) {
            result.error("INITIALIZATION_FAILED", e.message, null)
        }
    }

    private fun setupPosLink(result: Result) {
        if (teyaPosLinkSDK == null) {
            result.error("SDK_NOT_INITIALIZED", "SDK is not initialized", null)
            return
        }

        teyaPosLinkSDK!!.setup(
            onFailure = { failure ->
                result.error("SETUP_FAILED", failure.toString(), null)
            },
            onSuccess = { integration ->
                teyaPosLinkIntegration = integration
                result.success(null)
            }
        )
    }

    private fun makePayment(call: MethodCall, result: Result) {
        if (teyaPosLinkIntegration == null) {
            result.error("INTEGRATION_NOT_SETUP", "PosLink integration is not setup", null)
            return
        }

        try {
            val args = call.arguments as Map<String, Any>
            val amount = args["amount"] as Int
            val currency = args["currency"] as String
            val transactionId = args["transactionId"] as? String ?: UUID.randomUUID().toString()
            val tip = args["tip"] as? Int

            val paymentSubscription = teyaPosLinkIntegration!!.makePayment(
                transactionId = transactionId,
                amount = amount,
                currency = currency,
                tip = tip
            )

            currentPaymentSubscription = paymentSubscription

            val listener = object : PaymentStateSubscription.PaymentStateChangeListener {
                override fun onPaymentStateChanged(state: PaymentStateSubscription.PaymentStateDetails) {
                    // Send state change to Flutter
                    paymentStateEventSink?.success(mapOf(
                        "state" to state.state.name.lowercase(),
                        "reason" to (state.reason?.name?.lowercase()),
                        "isFinal" to state.isFinal,
                        "eposTransactionId" to state.eposTransactionId,
                        "metadata" to state.metadata
                    ))

                    // Handle final states
                    if (state.isFinal) {
                        when (state.state) {
                            PaymentStateSubscription.PaymentState.Successful -> {
                                result.success(mapOf(
                                    "isSuccess" to true,
                                    "transactionId" to transactionId,
                                    "eposTransactionId" to state.eposTransactionId,
                                    "finalState" to "successful",
                                    "metadata" to state.metadata
                                ))
                            }
                            PaymentStateSubscription.PaymentState.ProcessingFailed,
                            PaymentStateSubscription.PaymentState.Canceled,
                            PaymentStateSubscription.PaymentState.CommunicationFailed -> {
                                result.error("PAYMENT_FAILED", "Payment failed: ${state.state}", mapOf(
                                    "transactionId" to transactionId,
                                    "finalState" to state.state.name.lowercase(),
                                    "reason" to state.reason?.name?.lowercase(),
                                    "metadata" to state.metadata
                                ))
                            }
                            else -> {
                                // Handle other final states if needed
                            }
                        }
                    }
                }
            }

            paymentSubscription.subscribe(listener)
            paymentStateListeners[transactionId] = listener

        } catch (e: Exception) {
            result.error("PAYMENT_ERROR", e.message, null)
        }
    }

    private fun cancelPayment(result: Result) {
        currentPaymentSubscription?.cancelPayment { cancellationResult ->
            result.success(cancellationResult.toString() == "SUCCESS")
        } ?: result.success(false)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        paymentStateChannel.setStreamHandler(null)
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
        activity = null
    }

    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        paymentStateEventSink = events
    }

    override fun onCancel(arguments: Any?) {
        paymentStateEventSink = null
    }
}

// Logger implementation for Flutter
class FlutterLogger : com.teya.unifiedepossdk.commons.Logger {
    override fun logd(tag: String, message: String) {
        Log.d("TeyaSDK", "[$tag] $message")
    }

    override fun logi(tag: String, message: String) {
        Log.i("TeyaSDK", "[$tag] $message")
    }

    override fun logw(tag: String, message: String) {
        Log.w("TeyaSDK", "[$tag] $message")
    }

    override fun loge(tag: String, message: String) {
        Log.e("TeyaSDK", "[$tag] $message")
    }
}

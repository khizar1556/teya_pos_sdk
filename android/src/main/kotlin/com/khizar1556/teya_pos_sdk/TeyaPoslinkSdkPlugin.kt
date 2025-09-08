package com.khizar1556.teya_pos_sdk

import android.app.Activity
import android.content.Context
import android.util.Log
import com.teya.unifiedepossdk.GatewayPaymentId
import com.teya.unifiedepossdk.PaymentStateSubscription
import com.teya.unifiedepossdk.TeyaCommonTransactionsApi
import com.teya.unifiedepossdk.TeyaPosLinkSDK
import com.teya.unifiedepossdk.poslink.PosLinkSDK
import com.teya.unifiedepossdk.poslink.PosLinkSDK.Failure
import com.teya.sdkutilities.Logger
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

    private var teyaPosLinkSDK: PosLinkSDK? = null
    private var teyaIntegration: TeyaCommonTransactionsApi? = null
    private var paymentStateEventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "teya_pos_sdk")
        channel.setMethodCallHandler(this)
        
        paymentStateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "teya_pos_sdk/payment_state")
        paymentStateChannel.setStreamHandler(this)
        
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initialize(call, result)
            "setupPosLink" -> setupPosLink(result)
            "makePayment" -> makePayment(call, result)
            "cancelPayment" -> cancelPayment(result)
            "isReadyForUI" -> checkUIAvailability(result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(call: MethodCall, result: Result) {
        try {
            val config = call.arguments as Map<String, Any>
            val isProductionEnv = config["isProductionEnv"] as? Boolean ?: false

            teyaPosLinkSDK = TeyaPosLinkSDK(
                isProductionEnv = isProductionEnv, // Set to true for production
                authConfig = PosLinkSDK.AuthConfig.Managed(
                    clientId = config["clientId"] as String,
                    clientSecret = config["clientSecret"] as String
                ),
                eposInstanceId = null,  // Optional: identifier for your ePOS app instance
                logger = FlutterLogger()   // Optional: your custom logger implementation
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

        // Ensure we have an activity context for UI navigation
        if (activity == null) {
            result.error("ACTIVITY_NOT_AVAILABLE", "Activity context is not available for UI navigation", null)
            return
        }

        // Run on UI thread to ensure proper context
        activity!!.runOnUiThread {
            try {
                Log.d("TeyaSDK", "Starting PosLink setup with activity context: ${activity!!.javaClass.simpleName}")
                teyaPosLinkSDK!!.setupTransactionsApi(
                    onFailure = { failure ->
                        Log.e("TeyaSDK", "PosLink setup failed: $failure")
                        result.error("SETUP_FAILED", failure.toString(), null)
                    },
                    onSuccess = { integration ->
                        Log.d("TeyaSDK", "PosLink setup successful")
                        teyaIntegration = integration
                        result.success(null)
                    }
                )
            } catch (e: Exception) {
                Log.e("TeyaSDK", "Exception during PosLink setup: ${e.message}", e)
                result.error("SETUP_EXCEPTION", e.message, null)
            }
        }
    }

    private fun makePayment(call: MethodCall, result: Result) {
        if (teyaIntegration == null) {
            result.error("INTEGRATION_NOT_SETUP", "PosLink integration is not setup", null)
            return
        }

        try {
            val args = call.arguments as Map<String, Any>
            val amount = args["amount"] as Int
            val currency = args["currency"] as String
            val transactionId = args["transactionId"] as? String ?: UUID.randomUUID().toString()
            val tip = args["tip"] as? Int

            val paymentSubscription = teyaIntegration!!.makePayment(
                transactionId = transactionId,
                amount = amount,
                currency = currency,
                tip = tip
            )

            val listener = object : PaymentStateSubscription.PaymentStateChangeListener {
                override fun onPaymentStateChanged(state: PaymentStateSubscription.PaymentStateDetails) {
                    // Send state change to Flutter
                    paymentStateEventSink?.success(state.toMap())
                   /* paymentStateEventSink?.success(mapOf(
                        "state" to state.state.name.lowercase(),
                        "reason" to (state.reason?.name?.lowercase()),
                        "isFinal" to state.isFinal,
                        "eposTransactionId" to state.eposTransactionId,
                        "gatewayPaymentId" to state.gatewayPaymentId?.id,
                        "amount" to state.amount,
                        "tip" to state.tip,
                        "currency" to state.currency,
                        "metadata" to state.metadata
                    ))
                    */

                    // Handle final states
                    if (state.isFinal) {
                        when (state.state) {
                            PaymentStateSubscription.PaymentState.Successful -> {
                               /* result.success(mapOf(
                                    "isSuccess" to true,
                                    "transactionId" to transactionId,
                                    "eposTransactionId" to state.eposTransactionId,
                                    "gatewayPaymentId" to state.gatewayPaymentId,
                                    "finalState" to "successful",
                                    "metadata" to state.metadata
                                ))*/
                                result.success(state.toMap())
                            }
                            PaymentStateSubscription.PaymentState.ProcessingFailed,
                            PaymentStateSubscription.PaymentState.Canceled,
                            PaymentStateSubscription.PaymentState.CommunicationFailed -> {
                                result.error("PAYMENT_FAILED", "Payment failed: ${state.state}", state.toMap())
                            }
                            else -> {
                                // Handle other final states if needed
                            }
                        }
                    }
                }
            }

            paymentSubscription.subscribe(listener)

        } catch (e: Exception) {
            result.error("PAYMENT_ERROR", e.message, null)
        }
    }

    private fun cancelPayment(result: Result) {
        // Note: In the new SDK, cancellation is handled differently
        // You would need to store the payment subscription and call unsubscribe
        result.success(false) // Placeholder - implement based on your needs
    }

    private fun checkUIAvailability(result: Result) {
        val isReady = activity != null && teyaPosLinkSDK != null
        result.success(mapOf(
            "isReady" to isReady,
            "hasActivity" to (activity != null),
            "hasSDK" to (teyaPosLinkSDK != null),
            "activityType" to (activity?.javaClass?.simpleName ?: "null")
        ))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        paymentStateChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d("TeyaSDK", "Activity attached: ${activity?.javaClass?.simpleName}")
        binding.addActivityResultListener { requestCode, resultCode, data ->
            Log.d("TeyaSDK", "Activity result: $requestCode $resultCode $data")
            false // SDK ko propagate karna zaroori ho sakta hai
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d("TeyaSDK", "Activity detached for config changes")
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d("TeyaSDK", "Activity reattached after config changes: ${activity?.javaClass?.simpleName}")
    }

    override fun onDetachedFromActivity() {
        Log.d("TeyaSDK", "Activity detached")
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
class FlutterLogger : Logger {
    override fun d(message: String) {
        Log.d("TeyaSDK", message)
    }

    override fun i(message: String) {
        Log.i("TeyaSDK", message)
    }

    override fun w(message: String) {
        Log.w("TeyaSDK", message)
    }

    override fun e(message: String) {
        Log.e("TeyaSDK", message)
    }
}
fun PaymentStateSubscription.PaymentStateDetails.toMap(): Map<String, Any?> {
    return mapOf(
        "eposTransactionId" to eposTransactionId,
        "amount" to amount,
        "tip" to tip,
        "currency" to currency,
        "state" to state.toString(),
        "gatewayPaymentId" to gatewayPaymentId?.toMap(),
        "reason" to reason,
        "metadata" to metadata?.toMap(),
        "wasUnsubscribed" to wasUnsubscribed
    )
}

fun PaymentStateSubscription.PaymentStateDetails.Metadata.toMap(): Map<String, Any?> {
    return mapOf(
        "card" to card?.toMap(),
        "entryMode" to entryMode.toString(),
        "verificationMethod" to (verificationMethod?.name ?: ""),
        "applicationId" to applicationId,
        "merchantAcquiringId" to merchantAcquiringId,
        "responseCode" to responseCode,
        "authorisationCode" to authorisationCode
    )
}

fun PaymentStateSubscription.PaymentStateDetails.Metadata.Card.toMap(): Map<String, Any?> {
    return mapOf(
        "last4" to last4,
        "issuingCountry" to issuingCountry,
        "brand" to brand.name,
        "type" to (type?.name ?: "")
    )
}
fun GatewayPaymentId.toMap(): Map<String, Any?> {
    return mapOf(
        "id" to id,
    )
}

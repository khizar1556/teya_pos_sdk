import Flutter
import UIKit

public class TeyaPoslinkSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "teya_pos_sdk", binaryMessenger: registrar.messenger())
        let instance = TeyaPoslinkSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "teya_pos_sdk/payment_state", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // All methods return platform not supported error
        result(FlutterError(
            code: "PLATFORM_NOT_SUPPORTED",
            message: "iOS platform is not supported by Teya SDK. Please use Android for payment processing.",
            details: [
                "platform": "iOS",
                "supported_platforms": ["Android"],
                "reason": "Teya SDK does not provide iOS support yet"
            ]
        ))
    }
    
    // FlutterStreamHandler implementation
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        // Return error immediately for iOS
        return FlutterError(
            code: "PLATFORM_NOT_SUPPORTED",
            message: "iOS platform is not supported by Teya SDK. Please use Android for payment processing.",
            details: [
                "platform": "iOS",
                "supported_platforms": ["Android"],
                "reason": "Teya SDK does not provide iOS support yet"
            ]
        )
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

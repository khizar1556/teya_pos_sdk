import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teya_pos_sdk/teya_pos_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teya SDK Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TeyaPaymentPage(),
    );
  }
}

class TeyaPaymentPage extends StatefulWidget {
  const TeyaPaymentPage({super.key});

  @override
  State<TeyaPaymentPage> createState() => _TeyaPaymentPageState();
}

class _TeyaPaymentPageState extends State<TeyaPaymentPage> {
  final TeyaSdk _teyaSdk = TeyaSdk.instance;
  final TextEditingController _amountController =
      TextEditingController(text: '5.50');
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _clientSecretController = TextEditingController();

  bool _isInitialized = false;
  bool _isProcessing = false;
  String _status = 'Not initialized';
  String _lastTransactionId = '';
  StreamSubscription<PaymentStateDetails>? _paymentStateSubscription;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Initialize SDK after the first frame is rendered to avoid blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _initializeSdk(); // Uncomment when ready to auto-initialize
    });
  }

  @override
  void dispose() {
    _paymentStateSubscription?.cancel();
    _debounceTimer?.cancel();
    _teyaSdk.dispose();
    _amountController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  Future<void> _initializeSdk() async {
    try {
      // Update UI immediately for better UX
      if (mounted) {
        setState(() {
          _status = 'Initializing SDK...';
        });
      }

      final config = TeyaConfig.sandbox(
        clientId: _clientIdController.text,
        clientSecret: _clientSecretController.text,
      );

      // Perform heavy operations
      if (!_teyaSdk.isInitialized) {
        await _teyaSdk.initialize(config);
      }

      // Check if SDK is ready for UI operations
      final uiStatus = await _teyaSdk.isReadyForUI();
      if (mounted) {
        setState(() {
          _status =
              'Checking UI readiness... ${uiStatus['isReady'] ? 'Ready' : 'Not ready'}';
        });
      }

      if (!uiStatus['isReady']) {
        throw Exception(
            'SDK not ready for UI operations. Activity: ${uiStatus['hasActivity']}, SDK: ${uiStatus['hasSDK']}');
      }

      await _teyaSdk.setupPosLink();

      // Update UI after successful initialization
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _status = 'SDK initialized successfully';
        });

        // Listen to payment state changes with error handling and debouncing
        _paymentStateSubscription = _teyaSdk.paymentStateStream.listen(
          (state) {
            if (mounted) {
              // Debounce rapid state updates to prevent excessive UI rebuilds
              _debounceTimer?.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 100), () {
                if (mounted) {
                  setState(() {
                    _status =
                        'Payment state: ${state.state.name} (Final: ${state.isFinal})\n(Data : ${state.toString()})';
                  });
                }
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _status = 'Payment stream error: $error';
              });
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Initialization failed: $e';
        });
      }
    }
  }

  Future<void> _makePayment() async {
    if (!_isInitialized || _isProcessing) return;

    try {
      // Update UI immediately
      if (mounted) {
        setState(() {
          _isProcessing = true;
          _status = 'Processing payment...';
        });
      }

      final amount = double.tryParse(_amountController.text) ?? 0.0;

      // Perform payment operation
      final result = await _teyaSdk.makePaymentGBP(
        amountInPounds: amount,
      );

      // Update UI after payment completion
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _lastTransactionId = result.transactionId ?? 'Unknown';
          _status = result.isSuccess
              ? 'Payment successful! Transaction ID: ${result.transactionId}'
              : 'Payment failed: ${result.errorMessage}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _status = 'Payment error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Teya ePOS SDK Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuration',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _clientIdController,
                        decoration: const InputDecoration(
                          labelText: 'Client ID',
                          hintText: 'Enter your Teya client ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _clientSecretController,
                        decoration: const InputDecoration(
                          labelText: 'Client Secret',
                          hintText: 'Enter your Teya client secret',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isInitialized ? null : _initializeSdk,
                        child: Text(
                            _isInitialized ? 'Initialized' : 'Initialize SDK'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount (GBP)',
                          border: OutlineInputBorder(),
                          prefixText: '£',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isInitialized && !_isProcessing
                            ? _makePayment
                            : null,
                        child: Text(
                            _isProcessing ? 'Processing...' : 'Make Payment'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _status,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (_lastTransactionId.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Last Transaction ID: $_lastTransactionId',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructions',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Enter your Teya client credentials\n'
                        '2. Click "Initialize SDK"\n'
                        '3. Enter payment amount\n'
                        '4. Click "Make Payment"\n'
                        '5. Follow the prompts on the payment terminal',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

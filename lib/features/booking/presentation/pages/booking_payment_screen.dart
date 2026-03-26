import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingPaymentScreen extends StatefulWidget {
  final String tripId;

  const BookingPaymentScreen({super.key, required this.tripId});

  @override
  State<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Simulate payment processing on load
    _simulatePayment();
  }

  Future<void> _simulatePayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/booking/success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Processing Payment...'),
            ] else ...[
               // Fallback UI if auto-processing didn't trigger or for manual retry
              const Icon(Icons.qr_code_2, size: 200),
              const SizedBox(height: 16),
              const Text('Scan to Pay'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _simulatePayment,
                child: const Text('Simulate Payment Success'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

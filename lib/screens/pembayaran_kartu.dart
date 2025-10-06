import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PembayaranKartuScreen extends StatelessWidget {
  final double totalAmount;

  const PembayaranKartuScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Kartu Debit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(totalAmount)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.credit_card,
                      size: 100,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tempel atau masukkan kartu debit Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Simulasi pembayaran berhasil
                          Navigator.pop(context);
                        },
                        child: const Text('Selesai'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
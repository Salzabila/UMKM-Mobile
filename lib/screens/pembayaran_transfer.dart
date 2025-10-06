import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PembayaranTransferScreen extends StatelessWidget {
  final double totalAmount;

  const PembayaranTransferScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Bank'),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Transfer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBankInfo('Bank BCA', '1234567890', 'John Doe'),
                    const SizedBox(height: 12),
                    _buildBankInfo('Bank Mandiri', '0987654321', 'John Doe'),
                    const SizedBox(height: 12),
                    _buildBankInfo('Bank BNI', '5678901234', 'John Doe'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: Center(
                child: Text(
                  'Transfer sesuai nominal di atas ke salah satu rekening yang tersedia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfo(String bankName, String accountNumber, String accountName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bankName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('No. Rekening: $accountNumber'),
        Text('Atas Nama: $accountName'),
      ],
    );
  }
}
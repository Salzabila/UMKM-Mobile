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
      body: Column(
        children: [
          _buildGradientHeader(
            context,
            title: 'Transfer Bank',
            subtitle: 'Transfer sesuai nominal',
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAmountCard(context),
                  const SizedBox(height: 16),
                  _buildInformasiTransfer(context),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Saya sudah transfer'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context, {required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4FACFE), Color(0xFF8F6BFF)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _roundIconButton(context, Icons.arrow_back_rounded, () => Navigator.pop(context)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _roundIconButton(context, Icons.info_outline_rounded, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(
            'Rp ${NumberFormat('#,##0', 'id_ID').format(totalAmount)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildInformasiTransfer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Transfer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _bankTile('Bank BCA', '1234567890', 'John Doe'),
          const Divider(height: 24),
          _bankTile('Bank Mandiri', '0987654321', 'John Doe'),
          const Divider(height: 24),
          _bankTile('Bank BNI', '5678901234', 'John Doe'),
          const SizedBox(height: 12),
          const Text(
            'Transfer sesuai nominal di atas ke salah satu rekening, lalu unggah bukti di kasir bila diperlukan.',
            style: TextStyle(fontSize: 12.5, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _bankTile(String bank, String norek, String an) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.account_balance_rounded, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bank, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('No. Rek: $norek'),
              Text('a.n. $an'),
            ],
          ),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.copy_rounded)),
      ],
    );
  }

  Widget _roundIconButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
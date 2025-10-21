import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaksi.dart';
import '../widgets/struk_widget.dart';
import 'main_navigation.dart';

class TransaksiBerhasilScreen extends StatefulWidget {
  final Transaksi transaksi;
  const TransaksiBerhasilScreen({super.key, required this.transaksi});

  @override
  State<TransaksiBerhasilScreen> createState() =>
      _TransaksiBerhasilScreenState();
}

class _TransaksiBerhasilScreenState extends State<TransaksiBerhasilScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isProcessing = false;

  // MODERN COLOR PALETTE
  static const Color _primaryColor = Color(0xFF6366F1);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _infoColor = Color(0xFF3B82F6);
  
  static const Color _bgColor = Color(0xFFFAFAFA);
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _textTertiary = Color(0xFF9CA3AF);
  static const Color _borderColor = Color(0xFFE5E7EB);

  static final BoxShadow _softShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 16,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );

  static final BoxShadow _floatingShadow = BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 32,
    offset: const Offset(0, 12),
    spreadRadius: -8,
  );

  Future<Uint8List> _captureStruk() async {
    final imageBytes = await _screenshotController.captureFromWidget(
      Material(
        child: WidgetStruk(transaksi: widget.transaksi),
      ),
      delay: const Duration(milliseconds: 100),
    );
    return imageBytes;
  }

  Future<void> _cetakStruk() async {
    setState(() => _isProcessing = true);
    try {
      final imageBytes = await _captureStruk();
      bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (!isConnected) {
        List<BluetoothInfo> devices =
            await PrintBluetoothThermal.pairedBluetooths;
        if (devices.isEmpty) {
          throw Exception("Tidak ada printer Bluetooth terpasang.");
        }
        await PrintBluetoothThermal.connect(
            macPrinterAddress: devices.first.macAdress);
      }
      final img.Image image = img.decodeImage(imageBytes)!;
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];
      bytes += generator.image(image);
      await PrintBluetoothThermal.writeBytes(bytes);
      if (mounted) {
        _showSuccessSnackBar('Struk berhasil dicetak');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Gagal mencetak: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _shareStruk() async {
    setState(() => _isProcessing = true);
    try {
      final imageBytes = await _captureStruk();
      final file = XFile.fromData(
        imageBytes,
        name: 'struk-${widget.transaksi.id}.png',
        mimeType: 'image/png',
      );
      await Share.shareXFiles([file],
          text: 'Struk Transaksi - ${widget.transaksi.nomerNota}');
      if (mounted) {
        _showSuccessSnackBar('Struk berhasil dibagikan');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Gagal membagikan: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, 
                style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          'Transaksi Berhasil',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: _textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: _surfaceColor,
        foregroundColor: _textPrimary,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _borderColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSuccessCard(),
          const SizedBox(height: 20),
          _buildTransactionInfo(),
          const SizedBox(height: 20),
          _buildItemsList(),
          const SizedBox(height: 20),
          _buildPaymentSummary(),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_successColor, Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _successColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pembayaran Berhasil!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Transaksi telah berhasil diproses',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Rp ${NumberFormat('#,##0', 'id_ID').format(widget.transaksi.total)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _successColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_softShadow],
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded, 
                    color: _primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informasi Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('No. Transaksi', widget.transaksi.nomerNota),
          const SizedBox(height: 12),
          _buildInfoRow('Tanggal', 
              DateFormat('dd MMM yyyy, HH:mm').format(widget.transaksi.waktuTransaksi)),
          const SizedBox(height: 12),
          _buildInfoRow('Kasir', widget.transaksi.petugas),
          const SizedBox(height: 12),
          _buildInfoRow('Metode Pembayaran', widget.transaksi.metodeBayar),
          if (widget.transaksi.pelangganNama != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Pelanggan', widget.transaksi.pelangganNama!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(
            fontSize: 14,
            color: _textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_softShadow],
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_bag_rounded, 
                    color: _warningColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Item Pembelian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.transaksi.items.length} item',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _warningColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.transaksi.items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: _primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.barang.namaBarang,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.kuantitas}x @ Rp ${NumberFormat('#,##0', 'id_ID').format(item.barang.harga)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rp ${NumberFormat('#,##0', 'id_ID').format(item.barang.harga * item.kuantitas)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_softShadow],
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payments_rounded, 
                    color: _successColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Rincian Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Total Tagihan', 
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(widget.transaksi.total)}'),
                const SizedBox(height: 12),
                const Divider(height: 1, color: _borderColor),
                const SizedBox(height: 12),
                _buildSummaryRow('Uang Diterima', 
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(widget.transaksi.uangDiterima)}'),
                const SizedBox(height: 12),
                const Divider(height: 1, color: _borderColor),
                const SizedBox(height: 12),
                _buildSummaryRow('Kembalian', 
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(widget.transaksi.kembalian)}',
                    isHighlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            color: isHighlight ? _successColor : _textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 18 : 15,
            fontWeight: FontWeight.w700,
            color: isHighlight ? _successColor : _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [_floatingShadow],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.all(24),
              child: const Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memproses...',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareStruk,
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: const Text('Bagikan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryColor,
                      side: const BorderSide(color: _primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _cetakStruk,
                    icon: const Icon(Icons.print_rounded, size: 20),
                    label: const Text('Cetak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _successColor,
                      side: const BorderSide(color: _successColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                icon: const Icon(Icons.add_business_rounded, size: 20),
                label: const Text('Transaksi Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
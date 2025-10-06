import './keranjang.dart'; 

class Transaksi {
  final String id;
  final String nomerNota;
  final DateTime waktuTransaksi;
  final String petugas;
  final String metodeBayar;
  final String status;
  final List<KeranjangItem> items;
  final double total;
  final double uangDiterima;
  final double kembalian;
  final String? pelangganId;
  final String? pelangganNama;

  Transaksi({
    required this.id,
    required this.nomerNota,
    required this.waktuTransaksi,
    required this.petugas,
    required this.metodeBayar,
    required this.status,
    required this.items, 
    required this.total,
    this.uangDiterima = 0.0, 
    this.kembalian = 0.0,
    this.pelangganId,
    this.pelangganNama,
  });
}
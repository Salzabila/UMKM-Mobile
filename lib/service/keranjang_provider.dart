import 'package:flutter/material.dart';
import '../models/keranjang.dart';
import '../models/barang.dart';
import '../utils/enums.dart';
import '../models/pelanggan.dart';

class KeranjangProvider with ChangeNotifier {
  final Map<String, KeranjangItem> _items = {};
  DiskonTipe _diskonTipe = DiskonTipe.nominal;
  double _diskonValue = 0.0;
  String _metodePembayaran = 'Tunai';
  Pelanggan? _pelanggan;

  // Getters
  Map<String, KeranjangItem> get items => {..._items};
  DiskonTipe get diskonTipe => _diskonTipe;
  double get diskonValue => _diskonValue;
  String get metodePembayaran => _metodePembayaran;
  Pelanggan? get pelanggan => _pelanggan;

  int get jumlahItem {
    int total = 0;
    _items.forEach((key, item) { total += item.kuantitas; });
    return total;
  }

  double get subtotal {
    double total = 0.0;
    _items.forEach((key, item) { total += item.barang.harga * item.kuantitas; });
    return total;
  }
  
  double get diskon {
    if (_diskonTipe == DiskonTipe.nominal) return _diskonValue;
    if (_diskonTipe == DiskonTipe.persen) return subtotal * (_diskonValue / 100);
    return 0.0;
  }

  double get totalHarga {
    final totalAkhir = subtotal - diskon;
    return totalAkhir < 0 ? 0 : totalAkhir;
  }
  
  // Aksi / Mutasi
  void pilihPelanggan(Pelanggan pelanggan) {
    _pelanggan = pelanggan;
    notifyListeners();
  }

  void hapusPelanggan() {
    _pelanggan = null;
    notifyListeners();
  }

  void pilihMetodePembayaran(String metode) {
    _metodePembayaran = metode;
    notifyListeners();
  }

  void terapkanDiskon({required double value, required DiskonTipe tipe}) {
    _diskonValue = value;
    _diskonTipe = tipe;
    notifyListeners();
  }

  void hapusDiskon() {
    _diskonValue = 0.0;
    _diskonTipe = DiskonTipe.nominal;
    notifyListeners();
  }

  void tambahProduk(Barang produk) {
    if (_items.containsKey(produk.id)) {
      _items.update(produk.id, (item) => KeranjangItem(barang: item.barang, kuantitas: item.kuantitas + 1));
    } else {
      _items.putIfAbsent(produk.id, () => KeranjangItem(barang: produk));
    }
    notifyListeners();
  }
  
  void tambahProdukKustom({required String nama, required double harga, required int kuantitas}) {
    final produkKustom = Barang(
      id: 'kustom-${DateTime.now().toIso8601String()}',
      namaBarang: nama, jenis: 'Kustom', tanggalMasuk: DateTime.now(), stok: kuantitas, harga: harga,
    );
    _items.putIfAbsent(produkKustom.id, () => KeranjangItem(barang: produkKustom, kuantitas: kuantitas));
    notifyListeners();
  }

  void kurangiKuantitas(String produkId) {
    if (!_items.containsKey(produkId)) return;
    if (_items[produkId]!.kuantitas > 1) {
      _items.update(produkId, (item) => KeranjangItem(barang: item.barang, kuantitas: item.kuantitas - 1));
    } else {
      _items.remove(produkId);
    }
    notifyListeners();
  }

  // HANYA ADA SATU FUNGSI bersihkanKeranjang
  void bersihkanKeranjang() {
    _items.clear();
    hapusDiskon();
    _metodePembayaran = 'Tunai';
    _pelanggan = null;
    notifyListeners();
  }
}
import 'package:aplikasi_umkm/models/barang.dart';

class KeranjangItem {
  final Barang barang;
  int kuantitas;

  KeranjangItem({required this.barang, this.kuantitas = 1});
}
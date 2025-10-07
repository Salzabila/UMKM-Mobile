import 'package:hive_flutter/hive_flutter.dart';

part 'barang.g.dart'; // Untuk Hive code generation

@HiveType(typeId: 0)
class Barang extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String namaBarang;
  
  @HiveField(2)
  final String jenis;
  
  @HiveField(3)
  final DateTime tanggalMasuk;
  
  @HiveField(4)
  final DateTime? expired;
  
  @HiveField(5)
  int stok;
  
  @HiveField(6)
  final double harga;
  
  @HiveField(7)
  String? fotoUrl; // Tambahkan field foto

  Barang({
    required this.id,
    required this.namaBarang,
    required this.jenis,
    required this.tanggalMasuk,
    this.expired,
    required this.stok,
    required this.harga,
    this.fotoUrl,
  });

  // Copy with method
  Barang copyWith({
    String? id,
    String? namaBarang,
    String? jenis,
    DateTime? tanggalMasuk,
    DateTime? expired,
    int? stok,
    double? harga,
    String? fotoUrl,
  }) {
    return Barang(
      id: id ?? this.id,
      namaBarang: namaBarang ?? this.namaBarang,
      jenis: jenis ?? this.jenis,
      tanggalMasuk: tanggalMasuk ?? this.tanggalMasuk,
      expired: expired ?? this.expired,
      stok: stok ?? this.stok,
      harga: harga ?? this.harga,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}
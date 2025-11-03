import 'package:hive/hive.dart';
part 'return_barang.g.dart';

@HiveType(typeId: 3) // ID unik baru (Barang=0, Pelanggan=1, Biaya=2)
class ReturnBarang extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String barangId; // ID dari barang yang di-return

  @HiveField(2)
  final String namaBarang;

  @HiveField(3)
  final int jumlah;

  @HiveField(4)
  final String alasan;

  @HiveField(5)
  final DateTime tanggalReturn;
  
  @HiveField(6)
  final String petugas; // Siapa yang mencatat return

  ReturnBarang({
    required this.id,
    required this.barangId,
    required this.namaBarang,
    required this.jumlah,
    required this.alasan,
    required this.tanggalReturn,
    required this.petugas,
  });
}
import 'package:hive/hive.dart';
part 'biaya_operasional.g.dart';

@HiveType(typeId: 2) // ID unik baru (Barang=0, Pelanggan=1)
class BiayaOperasional extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String namaBiaya;

  @HiveField(2)
  double jumlah;

  @HiveField(3)
  DateTime tanggal;

  @HiveField(4)
  String? kategori;

  BiayaOperasional({
    required this.id,
    required this.namaBiaya,
    required this.jumlah,
    required this.tanggal,
    this.kategori,
  });
}
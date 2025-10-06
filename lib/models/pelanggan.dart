import 'package:hive/hive.dart';
part 'pelanggan.g.dart';

@HiveType(typeId: 1)
class Pelanggan extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String namaLengkap;
  @HiveField(2)
  String nomorHp;
  @HiveField(3)
  String? email;
  @HiveField(4)
  String? fotoPath;

  Pelanggan({
    required this.id,
    required this.namaLengkap,
    required this.nomorHp,
    this.email,
    this.fotoPath,
  });
}
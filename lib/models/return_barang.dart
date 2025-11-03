class ReturnBarang {
  final String id;
  final String barangId;
  final String namaBarang;
  final int jumlah;
  final String alasan;
  final DateTime tanggalReturn;
  final String petugas;

  ReturnBarang({
    required this.id,
    required this.barangId,
    required this.namaBarang,
    required this.jumlah,
    required this.alasan,
    required this.tanggalReturn,
    required this.petugas,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barangId': barangId,
      'namaBarang': namaBarang,
      'jumlah': jumlah,
      'alasan': alasan,
      'tanggalReturn': tanggalReturn.toIso8601String(),
      'petugas': petugas,
    };
  }

  factory ReturnBarang.fromJson(Map<String, dynamic> json) {
    return ReturnBarang(
      id: json['id'],
      barangId: json['barangId'],
      namaBarang: json['namaBarang'],
      jumlah: json['jumlah'],
      alasan: json['alasan'],
      tanggalReturn: DateTime.parse(json['tanggalReturn']),
      petugas: json['petugas'],
    );
  }
}

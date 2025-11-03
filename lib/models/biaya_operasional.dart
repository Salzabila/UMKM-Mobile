class BiayaOperasional {
  final String id;
  final String namaBiaya;
  final double jumlah;
  final DateTime tanggal;
  final String? kategori;

  BiayaOperasional({
    required this.id,
    required this.namaBiaya,
    required this.jumlah,
    required this.tanggal,
    this.kategori,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaBiaya': namaBiaya,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'kategori': kategori,
    };
  }

  factory BiayaOperasional.fromJson(Map<String, dynamic> json) {
    return BiayaOperasional(
      id: json['id'],
      namaBiaya: json['namaBiaya'],
      jumlah: json['jumlah'].toDouble(),
      tanggal: DateTime.parse(json['tanggal']),
      kategori: json['kategori'],
    );
  }
}

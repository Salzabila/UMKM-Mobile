class Barang {
  final String id;
  final String namaBarang;
  final String jenis;
  final DateTime tanggalMasuk;
  final DateTime? expired;
  final int stok;
  final double harga;
  final String? fotoUrl;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaBarang': namaBarang,
      'jenis': jenis,
      'tanggalMasuk': tanggalMasuk.toIso8601String(),
      'expired': expired?.toIso8601String(),
      'stok': stok,
      'harga': harga,
      'fotoUrl': fotoUrl,
    };
  }

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      namaBarang: json['namaBarang'],
      jenis: json['jenis'],
      tanggalMasuk: DateTime.parse(json['tanggalMasuk']),
      expired: json['expired'] != null ? DateTime.parse(json['expired']) : null,
      stok: json['stok'],
      harga: json['harga'].toDouble(),
      fotoUrl: json['fotoUrl'],
    );
  }
}

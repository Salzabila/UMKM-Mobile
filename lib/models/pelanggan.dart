class Pelanggan {
  final String id;
  final String namaLengkap;
  final String nomorHp;
  final String? email;
  final String? fotoPath;

  Pelanggan({
    required this.id,
    required this.namaLengkap,
    required this.nomorHp,
    this.email,
    this.fotoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaLengkap': namaLengkap,
      'nomorHp': nomorHp,
      'email': email,
      'fotoPath': fotoPath,
    };
  }

  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      id: json['id'],
      namaLengkap: json['namaLengkap'],
      nomorHp: json['nomorHp'],
      email: json['email'],
      fotoPath: json['fotoPath'],
    );
  }
}

import 'dart:math';
import '../models/barang.dart';
import '../models/transaksi.dart';
import '../models/biaya_operasional.dart';
import '../models/pelanggan.dart';
import '../models/keranjang.dart';
import '../service/barang_service.dart';
import '../service/transaksi_service.dart';
import '../service/biaya_operasional_service.dart';
import '../service/pelanggan_service.dart';

class DummyDataHelper {
  final BarangService _barangService = BarangService();
  final TransaksiService _transaksiService = TransaksiService();
  final BiayaOperasionalService _biayaService = BiayaOperasionalService();
  final PelangganService _pelangganService = PelangganService();
  final Random _random = Random();

  Future<void> isiSemuaDataDummy() async {
    print('🔄 Mulai mengisi data dummy...');

    // 1. Isi data barang
    await _isiDataBarang();
    print('✅ Data barang berhasil ditambahkan');

    // 2. Isi data pelanggan
    await _isiDataPelanggan();
    print('✅ Data pelanggan berhasil ditambahkan');

    // 3. Isi data biaya operasional
    await _isiDataBiayaOperasional();
    print('✅ Data biaya operasional berhasil ditambahkan');

    // 4. Isi data transaksi
    await _isiDataTransaksi();
    print('✅ Data transaksi berhasil ditambahkan');

    print('🎉 Semua data dummy berhasil ditambahkan!');
  }

  Future<void> _isiDataBarang() async {
    final dataBarang = [
      Barang(
        id: 'brg-001',
        namaBarang: 'Kopi Robusta Gayo',
        jenis: 'Minuman',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 10)),
        stok: 150,
        harga: 25000,
      ),
      Barang(
        id: 'brg-002',
        namaBarang: 'Susu UHT Cokelat',
        jenis: 'Minuman',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 5)),
        expired: DateTime.now().add(const Duration(days: 30)),
        stok: 80,
        harga: 7500,
      ),
      Barang(
        id: 'brg-003',
        namaBarang: 'Roti Tawar',
        jenis: 'Makanan',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 2)),
        expired: DateTime.now().add(const Duration(days: 5)),
        stok: 45,
        harga: 15000,
      ),
      Barang(
        id: 'brg-004',
        namaBarang: 'Mie Instan Goreng',
        jenis: 'Makanan',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 15)),
        expired: DateTime.now().add(const Duration(days: 180)),
        stok: 200,
        harga: 3500,
      ),
      Barang(
        id: 'brg-005',
        namaBarang: 'Teh Botol Sosro',
        jenis: 'Minuman',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 3)),
        expired: DateTime.now().add(const Duration(days: 60)),
        stok: 120,
        harga: 5000,
      ),
      Barang(
        id: 'brg-006',
        namaBarang: 'Snack Keripik',
        jenis: 'Makanan',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 7)),
        expired: DateTime.now().add(const Duration(days: 90)),
        stok: 75,
        harga: 8000,
      ),
      Barang(
        id: 'brg-007',
        namaBarang: 'Air Mineral 600ml',
        jenis: 'Minuman',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 1)),
        expired: DateTime.now().add(const Duration(days: 365)),
        stok: 300,
        harga: 3000,
      ),
      Barang(
        id: 'brg-008',
        namaBarang: 'Biscuit Crackers',
        jenis: 'Makanan',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 20)),
        expired: DateTime.now().add(const Duration(days: 120)),
        stok: 60,
        harga: 12000,
      ),
      Barang(
        id: 'brg-009',
        namaBarang: 'Kopi Susu Instan',
        jenis: 'Minuman',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 12)),
        expired: DateTime.now().add(const Duration(days: 240)),
        stok: 90,
        harga: 18000,
      ),
      Barang(
        id: 'brg-010',
        namaBarang: 'Permen Mix',
        jenis: 'Makanan',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 8)),
        expired: DateTime.now().add(const Duration(days: 150)),
        stok: 180,
        harga: 1000,
      ),
      Barang(
        id: 'brg-011',
        namaBarang: 'Cokelat Batangan',
        jenis: 'Makanan',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 4)),
        expired: DateTime.now().add(const Duration(days: 200)),
        stok: 50,
        harga: 15000,
      ),
      Barang(
        id: 'brg-012',
        namaBarang: 'Jus Buah Kemasan',
        jenis: 'Minuman',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 2)),
        expired: DateTime.now().add(const Duration(days: 45)),
        stok: 70,
        harga: 8500,
      ),
    ];

    for (var barang in dataBarang) {
      await _barangService.addBarang(barang);
    }
  }

  Future<void> _isiDataPelanggan() async {
    final dataPelanggan = [
      Pelanggan(
        id: 'plg-001',
        namaLengkap: 'Budi Santoso',
        nomorHp: '081234567890',
        email: 'budi.santoso@email.com',
      ),
      Pelanggan(
        id: 'plg-002',
        namaLengkap: 'Siti Aminah',
        nomorHp: '082345678901',
        email: 'siti.aminah@email.com',
      ),
      Pelanggan(
        id: 'plg-003',
        namaLengkap: 'Ahmad Rifai',
        nomorHp: '083456789012',
        email: 'ahmad.rifai@email.com',
      ),
      Pelanggan(
        id: 'plg-004',
        namaLengkap: 'Dewi Lestari',
        nomorHp: '084567890123',
        email: 'dewi.lestari@email.com',
      ),
      Pelanggan(
        id: 'plg-005',
        namaLengkap: 'Rina Marlina',
        nomorHp: '085678901234',
        email: 'rina.marlina@email.com',
      ),
      Pelanggan(
        id: 'plg-006',
        namaLengkap: 'Hendra Gunawan',
        nomorHp: '086789012345',
        email: 'hendra.gunawan@email.com',
      ),
      Pelanggan(
        id: 'plg-007',
        namaLengkap: 'Linda Wijaya',
        nomorHp: '087890123456',
        email: 'linda.wijaya@email.com',
      ),
      Pelanggan(
        id: 'plg-008',
        namaLengkap: 'Agus Prasetyo',
        nomorHp: '088901234567',
        email: 'agus.prasetyo@email.com',
      ),
    ];

    for (var pelanggan in dataPelanggan) {
      await _pelangganService.simpanPelanggan(pelanggan);
    }
  }

  Future<void> _isiDataBiayaOperasional() async {
    final now = DateTime.now();
    final dataBiaya = [
      BiayaOperasional(
        id: 'biaya-001',
        namaBiaya: 'Listrik Bulan ${_getNamaBulan(now.month)}',
        jumlah: 450000,
        tanggal: DateTime(now.year, now.month, 5),
        kategori: 'Utilitas',
      ),
      BiayaOperasional(
        id: 'biaya-002',
        namaBiaya: 'Gaji Karyawan',
        jumlah: 3500000,
        tanggal: DateTime(now.year, now.month, 1),
        kategori: 'Gaji',
      ),
      BiayaOperasional(
        id: 'biaya-003',
        namaBiaya: 'Sewa Toko',
        jumlah: 2500000,
        tanggal: DateTime(now.year, now.month, 1),
        kategori: 'Sewa',
      ),
      BiayaOperasional(
        id: 'biaya-004',
        namaBiaya: 'Air PDAM',
        jumlah: 150000,
        tanggal: DateTime(now.year, now.month, 10),
        kategori: 'Utilitas',
      ),
      BiayaOperasional(
        id: 'biaya-005',
        namaBiaya: 'Internet & WiFi',
        jumlah: 350000,
        tanggal: DateTime(now.year, now.month, 15),
        kategori: 'Utilitas',
      ),
      BiayaOperasional(
        id: 'biaya-006',
        namaBiaya: 'Perlengkapan Toko',
        jumlah: 250000,
        tanggal: DateTime(now.year, now.month, 12),
        kategori: 'Perlengkapan',
      ),
      BiayaOperasional(
        id: 'biaya-007',
        namaBiaya: 'Transportasi & Logistik',
        jumlah: 500000,
        tanggal: DateTime(now.year, now.month, 8),
        kategori: 'Transportasi',
      ),
      BiayaOperasional(
        id: 'biaya-008',
        namaBiaya: 'Kebersihan & Sanitasi',
        jumlah: 180000,
        tanggal: DateTime(now.year, now.month, 7),
        kategori: 'Kebersihan',
      ),
      BiayaOperasional(
        id: 'biaya-009',
        namaBiaya: 'Perawatan AC',
        jumlah: 300000,
        tanggal: DateTime(now.year, now.month, 20),
        kategori: 'Perawatan',
      ),
      BiayaOperasional(
        id: 'biaya-010',
        namaBiaya: 'Pajak & Administrasi',
        jumlah: 400000,
        tanggal: DateTime(now.year, now.month, 3),
        kategori: 'Pajak',
      ),
    ];

    for (var biaya in dataBiaya) {
      await _biayaService.simpanBiaya(biaya);
    }
  }

  Future<void> _isiDataTransaksi() async {
    final barangList = await _barangService.getBarang();
    final pelangganList = await _pelangganService.getSemuaPelanggan();

    final now = DateTime.now();
    int transaksiCounter = 1;

    // Buat 30 transaksi dummy untuk 30 hari terakhir
    for (int i = 0; i < 30; i++) {
      final tanggalTransaksi = now.subtract(Duration(days: i));

      // Buat 2-5 transaksi per hari
      final jumlahTransaksiPerHari = 2 + _random.nextInt(4);

      for (int j = 0; j < jumlahTransaksiPerHari; j++) {
        // Pilih pelanggan random atau tanpa pelanggan
        final usePelanggan = _random.nextBool();
        final pelanggan = usePelanggan && pelangganList.isNotEmpty
            ? pelangganList[_random.nextInt(pelangganList.length)]
            : null;

        // Pilih 1-5 barang random
        final jumlahItem = 1 + _random.nextInt(5);
        final items = <KeranjangItem>[];
        double totalHarga = 0;

        for (int k = 0; k < jumlahItem; k++) {
          final barang = barangList[_random.nextInt(barangList.length)];
          final jumlahBeli = 1 + _random.nextInt(5);
          final subtotal = barang.harga * jumlahBeli;

          items.add(KeranjangItem(
            barang: barang,
            kuantitas: jumlahBeli,
          ));

          totalHarga += subtotal;
        }

        // Pilih metode pembayaran random
        final metodePembayaran =
            ['Tunai', 'QRIS', 'Transfer'][_random.nextInt(3)];

        // Waktu transaksi random dalam hari tersebut (jam 8 pagi - 8 malam)
        final jam = 8 + _random.nextInt(13);
        final menit = _random.nextInt(60);
        final waktuTransaksi = DateTime(
          tanggalTransaksi.year,
          tanggalTransaksi.month,
          tanggalTransaksi.day,
          jam,
          menit,
        );

        // Generate nomor nota
        final nomorNota =
            'TRX-${waktuTransaksi.year}${waktuTransaksi.month.toString().padLeft(2, '0')}${waktuTransaksi.day.toString().padLeft(2, '0')}-${transaksiCounter.toString().padLeft(4, '0')}';

        // Hitung uang diterima dan kembalian (untuk tunai)
        double uangDiterima = totalHarga;
        double kembalian = 0;
        if (metodePembayaran == 'Tunai') {
          // Bulatkan ke atas ribuan terdekat untuk uang diterima
          uangDiterima = ((totalHarga / 1000).ceil() * 1000).toDouble();
          kembalian = uangDiterima - totalHarga;
        }

        final transaksi = Transaksi(
          id: 'trx-${DateTime.now().millisecondsSinceEpoch}-$i-$j',
          nomerNota: nomorNota,
          waktuTransaksi: waktuTransaksi,
          petugas: 'Admin',
          metodeBayar: metodePembayaran,
          status: 'Selesai',
          items: items,
          total: totalHarga,
          uangDiterima: uangDiterima,
          kembalian: kembalian,
          pelangganId: pelanggan?.id,
          pelangganNama: pelanggan?.namaLengkap,
        );

        await _transaksiService.simpanTransaksi(transaksi);
        transaksiCounter++;
      }
    }
  }

  String _getNamaBulan(int bulan) {
    const namaBulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return namaBulan[bulan - 1];
  }
}

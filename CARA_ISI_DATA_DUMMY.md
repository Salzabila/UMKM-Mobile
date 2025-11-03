# Cara Mengisi Data Dummy

## Langkah-Langkah

### 1. Akses Menu Data Dummy
- Buka aplikasi dan masuk ke Dashboard
- Klik icon **database** (ikon 🗄️) di pojok kanan atas header Dashboard
- Anda akan masuk ke halaman "Data Dummy"

### 2. Melihat Status Data
Halaman Data Dummy akan menampilkan:
- Jumlah Barang yang tersimpan
- Jumlah Pelanggan yang tersimpan
- Jumlah Biaya Operasional yang tersimpan

### 3. Mengisi Data Dummy
- Klik tombol **"ISI DATA DUMMY"**
- Tunggu proses selesai (biasanya 2-5 detik)
- Akan muncul notifikasi sukses jika berhasil

### 4. Data yang Ditambahkan
Ketika Anda mengisi data dummy, sistem akan menambahkan:

#### **Barang (12 item)**
- Kopi Robusta Gayo
- Susu UHT Cokelat
- Roti Tawar
- Mie Instan Goreng
- Teh Botol Sosro
- Snack Keripik
- Air Mineral 600ml
- Biscuit Crackers
- Kopi Susu Instan
- Permen Mix
- Cokelat Batangan
- Jus Buah Kemasan

Setiap barang memiliki:
- ID unik
- Nama barang
- Jenis (Makanan/Minuman)
- Tanggal masuk
- Tanggal expired (jika ada)
- Stok (bervariasi 10-300 unit)
- Harga (bervariasi Rp 1.000 - Rp 25.000)

#### **Pelanggan (8 orang)**
- Budi Santoso
- Siti Aminah
- Ahmad Rifai
- Dewi Lestari
- Rina Marlina
- Hendra Gunawan
- Linda Wijaya
- Agus Prasetyo

Setiap pelanggan memiliki:
- ID unik
- Nama lengkap
- Nomor HP
- Email

#### **Biaya Operasional (10 item)**
Berbagai kategori biaya untuk bulan berjalan:
- Listrik (Rp 450.000)
- Gaji Karyawan (Rp 3.500.000)
- Sewa Toko (Rp 2.500.000)
- Air PDAM (Rp 150.000)
- Internet & WiFi (Rp 350.000)
- Perlengkapan Toko (Rp 250.000)
- Transportasi & Logistik (Rp 500.000)
- Kebersihan & Sanitasi (Rp 180.000)
- Perawatan AC (Rp 300.000)
- Pajak & Administrasi (Rp 400.000)

**Total Biaya Operasional: Rp 8.580.000**

#### **Transaksi (60-150 transaksi)**
- Data transaksi untuk 30 hari terakhir
- 2-5 transaksi per hari
- Setiap transaksi berisi:
  - Nomor nota (format: TRX-YYYYMMDD-XXXX)
  - Waktu transaksi (jam 8 pagi - 8 malam)
  - 1-5 item barang random
  - Metode pembayaran (Tunai/QRIS/Transfer)
  - Pelanggan (random, bisa ada atau tidak)
  - Total harga
  - Uang diterima dan kembalian (untuk tunai)

### 5. Menghapus Semua Data
Jika ingin reset database:
- Klik tombol **"HAPUS SEMUA DATA"**
- Konfirmasi penghapusan
- Semua data barang, pelanggan, dan biaya operasional akan dihapus

⚠️ **Perhatian**: Transaksi tidak akan terhapus karena disimpan di memori (TransaksiService)

### 6. Mengecek Hasil
Setelah mengisi data dummy, Anda dapat:
- Kembali ke Dashboard untuk melihat statistik
- Buka **Manajemen Barang** untuk melihat daftar produk
- Buka **Pelanggan** untuk melihat data pelanggan
- Buka **Biaya Operasional** untuk melihat daftar biaya
- Buka **Rekapitulasi** untuk melihat laporan transaksi

## Tips Penggunaan

### Untuk Testing Fitur:
1. **Kasir/Transaksi**: Data barang sudah tersedia untuk dijual
2. **Restock**: Semua barang bisa di-restock dengan stok awal yang bervariasi
3. **Return Barang**: Ada beberapa produk dengan tanggal expired yang bisa di-return
4. **Notifikasi**: Beberapa produk memiliki expired date yang akan memicu notifikasi
5. **Dashboard**: Akan menampilkan data statistik lengkap dengan grafik
6. **Rekapitulasi**: Laporan penjualan 30 hari terakhir dengan berbagai filter

### Untuk Development:
- Gunakan data dummy untuk testing UI/UX
- Cek performa aplikasi dengan data dalam jumlah banyak
- Testing fitur search dan filter
- Validasi perhitungan total dan statistik

## Struktur File

```
lib/
├── utils/
│   └── dummy_data_helper.dart      # Helper untuk mengisi data dummy
└── screens/
    └── data_dummy_screen.dart      # UI untuk manage data dummy
```

## Kode Penting

### Memanggil Helper secara Manual
Jika ingin mengisi data dummy via kode:

```dart
import 'package:aplikasi_umkm/utils/dummy_data_helper.dart';

// Di dalam fungsi async
final helper = DummyDataHelper();
await helper.isiSemuaDataDummy();
```

### Mengecek Jumlah Data
```dart
import 'package:hive_flutter/hive_flutter.dart';

final barangBox = Hive.box<Barang>('barangBox');
print('Jumlah barang: ${barangBox.length}');

final pelangganBox = Hive.box<Pelanggan>('pelangganBox');
print('Jumlah pelanggan: ${pelangganBox.length}');

final biayaBox = Hive.box<BiayaOperasional>('biayaBox');
print('Jumlah biaya: ${biayaBox.length}');
```

## Troubleshooting

### Data Tidak Muncul
- Pastikan Anda sudah klik tombol "ISI DATA DUMMY"
- Coba restart aplikasi
- Periksa console untuk error messages

### Data Sudah Ada
- Fungsi isi data dummy **menambahkan** data, tidak mengganti
- Jika ingin reset, gunakan tombol "HAPUS SEMUA DATA" terlebih dahulu

### Performa Lambat
- Normal jika pertama kali mengisi data dummy (2-5 detik)
- Transaksi membutuhkan waktu lebih lama karena jumlahnya banyak (60-150)

## Update Dashboard

Setelah mengisi/menghapus data dummy, Dashboard akan otomatis refresh untuk menampilkan data terbaru.

---

**Dibuat untuk**: Aplikasi UMKM - Testing & Development
**Versi**: 1.0
**Tanggal**: 3 November 2025

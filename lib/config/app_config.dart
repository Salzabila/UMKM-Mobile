class AppConfig {
  // TODO: Ganti dengan URL Laravel backend Anda
  // Development
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api';

  // Production (uncomment saat deploy)
  // static const String apiBaseUrl = 'https://your-domain.com/api';

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';

  // Barang
  static const String barangEndpoint = '/barang';

  // Pelanggan
  static const String pelangganEndpoint = '/pelanggan';

  // Biaya Operasional
  static const String biayaOperasionalEndpoint = '/biaya-operasional';

  // Transaksi
  static const String transaksiEndpoint = '/transaksi';

  // Return Barang
  static const String returnBarangEndpoint = '/return-barang';

  // Dashboard
  static const String dashboardEndpoint = '/dashboard';

  // Upload
  static const String uploadFotoEndpoint = '/upload-foto';
  static const String deleteFotoEndpoint = '/delete-foto';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

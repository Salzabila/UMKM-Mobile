
class ApiConstants {
  // Base URL - SESUAIKAN dengan setup Anda
  // Untuk Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Untuk iOS Simulator
  // static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // Untuk Device Fisik (ganti dengan IP komputer Anda)
  // static const String baseUrl = 'http://192.168.1.100:8000/api';
  
  // Auth Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String profile = '/profile';
  
  // Dashboard Endpoints
  static const String dashboardSummary = '/dashboard/summary';
  static const String salesChart = '/dashboard/sales-chart';
  
  // Products Endpoints
  static const String products = '/products';
  static String productDetail(int id) => '/products/$id';
  
  // Categories Endpoints
  static const String categories = '/categories';
  
  // Transactions Endpoints
  static const String transactions = '/transactions';
  static const String todayTransactions = '/transactions/today';
  
  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

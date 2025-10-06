import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/auth_service.dart';
import './login.dart';
import './tutorial_screen.dart';
import './faq_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String _namaPengguna = "Memuat...";
  String _rolePengguna = "Memuat...";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaPengguna = prefs.getString('loggedInUsername') ?? 'Kasir';
      _rolePengguna = prefs.getString('userRole') ?? "Kasir";
    });
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService().logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header dengan background gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                // Avatar dengan shadow
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _namaPengguna,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _rolePengguna,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section: PENGATURAN
                _buildSectionTitle('PENGATURAN'),
                _buildMenuCard(
                  children: [
                    _buildMenuItem(
                      icon: Icons.language_rounded,
                      iconColor: Colors.blue,
                      text: 'Bahasa Aplikasi',
                      subtitle: 'Pilih bahasa yang diinginkan',
                      onTap: () {
                        // TODO: tampilkan dialog pilihan bahasa
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Section: BANTUAN & TUTORIAL
                _buildSectionTitle('BANTUAN & TUTORIAL'),
                _buildMenuCard(
                  children: [
                    _buildMenuItem(
                      icon: Icons.menu_book_rounded,
                      iconColor: Colors.green,
                      text: 'Tutorial Penggunaan',
                      subtitle: 'Pelajari cara menggunakan aplikasi',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TutorialScreen()),
                      ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      iconColor: Colors.orange,
                      text: 'FAQ',
                      subtitle: 'Pertanyaan yang sering diajukan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FAQScreen()),
                      ),    
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.support_agent_rounded,
                      iconColor: Colors.purple,
                      text: 'Kontak Bantuan',
                      subtitle: 'Hubungi tim support kami',
                      onTap: () {
                        // TODO: bisa arahkan ke WA / Email admin
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Section: TENTANG APLIKASI
                _buildSectionTitle('TENTANG APLIKASI'),
                _buildMenuCard(
                  children: [
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      iconColor: Colors.teal,
                      text: 'Versi Aplikasi 1.0.0',
                      subtitle: 'Informasi versi aplikasi',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: "Aplikasi UMKM",
                          applicationVersion: "1.0.0",
                          applicationIcon: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.shop, color: Colors.white),
                          ),
                          applicationLegalese: "Dikembangkan oleh Tim Mahasiswa UMKM",
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Logout Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade200, width: 1),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HELPER WIDGETS
  // ==========================================================
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.arrow_forward_ios, 
          size: 14, 
          color: Colors.grey[600],
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey[200],
      ),
    );
  }
}
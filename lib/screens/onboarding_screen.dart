    import 'package:flutter/material.dart';
    import 'package:shared_preferences/shared_preferences.dart';
    import 'package:smooth_page_indicator/smooth_page_indicator.dart';
    import 'package:aplikasi_umkm/screens/login.dart';




    class OnboardingScreen extends StatefulWidget {
      const OnboardingScreen({super.key});

      @override
      State<OnboardingScreen> createState() => _OnboardingScreenState();
    }

    class _OnboardingScreenState extends State<OnboardingScreen> {
      final _pageController = PageController();
      int _currentPage = 0;

    
      final List<Map<String, String>> onboardingPages = [
        {
          "image": "assets/images/transaksi.png",
          "title": "Transaksi Mudah",
          "description": "Buat mesin kasir hanya dengan genggamanmu"
        },
        {
          "image": "assets/images/scanbarcode.png", 
          "title": "Scan Barang",
          "description": "Bisa anda lakukan dengan hp anda"
        },
        {
          "image": "assets/images/nota.png", 
          "title": "Nota Pembelian",
          "description": "Nota pembelian bisa dikirim melalui email pelanggan anda, tidak perlu mengeluarkan uang untuk beli printer"
        }
      ];

      void _finishOnboarding() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenOnboarding', true);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }

      @override
      void dispose() {
        _pageController.dispose();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 64), 
                
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingPages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = onboardingPages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(page['image']!, height: 250),
                            const SizedBox(height: 48),
                            Text(
                              page['title']!,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page['description']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bagian Navigasi Bawah
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: _currentPage == onboardingPages.length - 1
                      ? ElevatedButton(
                          onPressed: _finishOnboarding,
                          child: const Text('Selesai'),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _finishOnboarding,
                              child: const Text('Lewati'),
                            ),
                            SmoothPageIndicator(
                              controller: _pageController,
                              count: onboardingPages.length,
                              effect: WormEffect(
                                dotHeight: 10,
                                dotWidth: 10,
                                activeDotColor: Theme.of(context).primaryColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              icon: const Icon(Icons.arrow_forward),
                              style: IconButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                            )
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      }
    }
    

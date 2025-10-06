import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<Map<String, String>> faqList = const [
    {
      "question": "Bagaimana cara login?",
      "answer": "Masukkan email dan password yang sudah terdaftar, lalu tekan tombol login."
    },
    {
      "question": "Apakah aplikasi tersedia dalam bahasa Inggris?",
      "answer": "Ya, Anda bisa mengganti bahasa aplikasi di menu Profil > Bahasa Aplikasi."
    },
    {
      "question": "Bagaimana jika saya lupa password?",
      "answer": "Gunakan fitur 'Lupa Password' di halaman login untuk mereset kata sandi Anda."
    },
    {
      "question": "Bagaimana cara menghubungi tim support?",
      "answer": "Anda bisa menghubungi kami melalui menu Kontak Bantuan di halaman Profil."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        itemCount: faqList.length,
        itemBuilder: (context, index) {
          final faq = faqList[index];
          return ExpansionTile(
            leading: const Icon(Icons.help_outline, color: Colors.blue),
            title: Text(
              faq["question"] ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(faq["answer"] ?? ""),
              )
            ],
          );
        },
      ),
    );
  }
}
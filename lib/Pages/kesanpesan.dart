import 'dart:ui';
import 'package:flutter/material.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  int _selectedCard = -1; // -1 artinya tidak ada yang aktif
  static const themeColor = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Kesan & Pesan PAM",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_selectedCard != -1)
            IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: themeColor,
                  size: 90,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Pemrograman Aplikasi Mobile",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Refleksi dan apresiasi selama proses pembelajaran",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Card 1
                _buildCard(
                  index: 0,
                  title: "Kesan Selama Pembelajaran",
                  content:
                      "Selama mengikuti mata kuliah Pemrograman Aplikasi Mobile, saya mendapatkan banyak pengalaman berharga dalam mengembangkan logika dan kreativitas. Setiap pertemuan memberikan tantangan baru yang mengasah kemampuan berpikir kritis dan problem solving. Belajar Flutter membuat saya lebih memahami bagaimana aplikasi modern bekerja secara efisien dan responsif.",
                ),

                // Card 2
                _buildCard(
                  index: 1,
                  title: "Pesan untuk Pembelajaran Selanjutnya",
                  content:
                      "Semoga pembelajaran PAM di masa mendatang semakin interaktif dan berbasis proyek nyata. Pendekatan yang kolaboratif antara dosen dan mahasiswa dapat meningkatkan motivasi belajar dan memperdalam pemahaman konsep. Terima kasih kepada dosen atas bimbingan dan kesabaran dalam membimbing kami selama perkuliahan.",
                ),

                const SizedBox(height: 40),
                const Text(
                  "“Belajar coding bukan tentang menghafal syntax,\n"
                  "tetapi tentang melatih logika dan kesabaran.”",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required int index,
    required String title,
    required String content,
  }) {
    final bool isActive = _selectedCard == index;
    final bool isOtherCardActive =
        _selectedCard != -1 && _selectedCard != index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCard = isActive ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? themeColor.withOpacity(0.35)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isActive ? 16 : 6,
              offset: isActive ? const Offset(0, 6) : const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.black87,
                height: 1.6,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

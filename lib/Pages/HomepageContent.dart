import 'package:final_project/Pages/Quiz/tebakbahasa.dart';
import 'package:final_project/Pages/Quiz/tebaklambang.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:final_project/Pages/Quiz/tebakbendera.dart';
import 'package:final_project/Pages/Quiz/tebakbenua.dart';
import 'package:final_project/Pages/Quiz/tebakibukota.dart';
import 'package:final_project/Pages/Quiz/tebakmatauang.dart';
import 'package:final_project/database/databasehelper.dart';

class HomePageContent extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onDataUpdated;

  const HomePageContent({
    super.key,
    required this.userData,
    this.onDataUpdated,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  final db = DatabaseHelper.instance;

  final List<Map<String, String>> carouselItems = [
    {
      'image': 'https://picsum.photos/id/1015/600/300',
      'text': 'Rusia punya 11 zona waktu',
    },
    {
      'image': 'https://picsum.photos/id/1016/600/300',
      'text': 'Islandia tidak memiliki nyamuk',
    },
    {
      'image': 'https://picsum.photos/id/1018/600/300',
      'text': 'Sudan Selatan adalah negara termuda',
    },
  ];

  // GETTER UNTUK STATUS PREMIUM - PERBAIKI DARI 'Premium' KE 'premium'
  bool get isPremium => widget.userData['subscription_status'] == 'premium';

  // METHOD UNTUK HITUNG LEVEL BERDASARKAN XP (kelipatan 10)
  int get userLevel {
    final xp = widget.userData['xp'] ?? 0;
    return (xp / 10).floor(); // Level naik setiap 10 XP
  }

  // METHOD UNTUK HITUNG PROGRESS MENUJU LEVEL BERIKUTNYA
  double get levelProgress {
    final xp = widget.userData['xp'] ?? 0;
    final currentLevelXP = userLevel * 10;
    final nextLevelXP = (userLevel + 1) * 10;
    final xpInCurrentLevel = xp - currentLevelXP;

    return xpInCurrentLevel / 10.0; // Progress 0.0 - 1.0
  }

  // METHOD UNTUK REFRESH DATA
  Future<void> _refreshData() async {
    widget.onDataUpdated?.call();
  }

  // METHOD UNTUK UPDATE XP SETELAH QUIZ
  Future<void> _updateUserAfterQuiz(int score, int xpEarned) async {
    try {
      final userId = widget.userData['id'];
      if (userId != null) {
        final currentXP = widget.userData['xp'] ?? 0;
        final newXP = currentXP + xpEarned;

        // Update XP di database
        await db.updateXP(userId, newXP);

        // Tambah score ke history
        await db.addScoreToHistory(userId, score);

        print(
          '✅ Quiz completed! Score: $score, XP earned: $xpEarned, Total XP: $newXP',
        );

        // Refresh data untuk update UI
        _refreshData();

        // Tampilkan snackbar sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Quiz Selesai! Score: $score'),
                Text(
                  '+$xpEarned XP • Level $userLevel',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error updating user after quiz: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
      );
    }
  }

  // NAVIGASI KE QUIZ PAGE
  void _navigateToQuiz(Widget quizPage, String quizType) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => quizPage),
    ).then((value) {
      // Jika kembali dari quiz dengan value true, refresh data
      if (value == true) {
        _refreshData();
      }
    });
  }

  // METHOD UNTUK SIMULASI QUIZ COMPLETION (UNTUK TESTING)
  void _simulateQuizCompletion(String quizName) {
    final score = 70 + (DateTime.now().millisecond % 30); // Random score 70-99
    final xpEarned = (score / 10).floor(); // XP berdasarkan score

    _updateUserAfterQuiz(score, xpEarned);
  }

  @override
  Widget build(BuildContext context) {
    final userXP = widget.userData['xp'] ?? 0;
    final username = widget.userData['username'] ?? "Teman";

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profil kiri atas
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=3',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "$userXP XP • Level $userLevel",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Notification icon dengan refresh
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _refreshData,
                          tooltip: 'Refresh Data',
                        ),
                        Stack(
                          children: [
                            Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.notifications_rounded),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // BODY
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshData();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sapaan
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hi, $username!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Badge status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isPremium ? Colors.amber : Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPremium ? 'PREMIUM' : 'FREE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isPremium
                          ? 'Selamat datang'
                          : 'Ada GeoFunFact! Hari ini nih',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Carousel
              CarouselSlider.builder(
                carouselController: _controller,
                itemCount: carouselItems.length,
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  viewportFraction: 0.8,
                  onPageChanged: (index, reason) =>
                      setState(() => _current = index),
                ),
                itemBuilder: (context, index, _) {
                  final isActive = index == _current;
                  final item = carouselItems[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        if (isActive)
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            item['image']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        // POSISI TEKS DIUBAH: bottom dari 15 menjadi 40 agar lebih ke atas
                        Positioned(
                          bottom: 40, // DIUBAH: dari 15 menjadi 40
                          left: 15,
                          right: 15, // Ditambahkan untuk konsistensi
                          child: Text(
                            item['text']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // === Card Quiz ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Row 1: Quiz Free untuk semua user
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuizCard(
                            "Tebak Bendera",
                            Icons.flag,
                            Colors.red,
                            Colors.blue,
                            FlagQuizPage(userData: widget.userData),
                            true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuizCard(
                            "Tebak Ibu Kota",
                            Icons.location_city,
                            Colors.deepPurple,
                            Colors.blue,
                            CapitalQuizPage(userData: widget.userData),
                            true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Row 2: Quiz Premium
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuizCard(
                            "Tebak Mata Uang",
                            Icons.attach_money,
                            Colors.green,
                            Colors.teal,
                            CurrencyQuizPage(userData: widget.userData),
                            isPremium, // Hanya untuk premium
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuizCard(
                            "Tebak Benua",
                            Icons.public,
                            Colors.orange,
                            Colors.blue,
                            ContinentQuizPage(userData: widget.userData),
                            isPremium, // Hanya untuk premium
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Row 3: Quiz Premium
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuizCard(
                            "Tebak Bahasa",
                            Icons.language,
                            Colors.pink,
                            Colors.blue,
                            LanguageQuizPage(userData: widget.userData),
                            isPremium, // Hanya untuk premium
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuizCard(
                            "Tebak Lambang Negara",
                            Icons.emoji_flags,
                            Colors.orange,
                            Colors.yellow,
                            EmblemQuizPage(userData: widget.userData),
                            isPremium, // Hanya untuk premium
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Info section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Progress Anda:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPremium
                                ? "• Level $userLevel (${userXP % 10}/10 XP menuju Level ${userLevel + 1})\n• Akses semua quiz tanpa batas\n• Dapatkan 2x lebih banyak XP"
                                : "• Level $userLevel (${userXP % 10}/10 XP menuju Level ${userLevel + 1})\n• Selesaikan quiz untuk mendapatkan XP\n• Upgrade ke Premium untuk akses penuh",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Testing Button (Hanya untuk development)
                    if (!isPremium) ...[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => _simulateQuizCompletion("Test Quiz"),
                        child: const Text("Test Quiz Completion (Dev)"),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(
    String title,
    IconData icon,
    Color color1,
    Color color2,
    Widget destination,
    bool unlocked,
  ) {
    return InkWell(
      onTap: unlocked
          ? () => _navigateToQuiz(destination, title)
          : () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Fitur ini hanya untuk pengguna Premium.'),
                action: SnackBarAction(
                  label: 'Upgrade',
                  onPressed: () {
                    // Navigate to subscription page
                  },
                ),
                duration: const Duration(seconds: 3),
              ),
            ),
      child: Stack(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color1, color2]),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 35),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      unlocked ? "Buka" : "Premium",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Icon(
                      unlocked ? Icons.lock_open : Icons.lock,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!unlocked)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: Colors.white, size: 40),
                    SizedBox(height: 8),
                    Text(
                      "PREMIUM",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

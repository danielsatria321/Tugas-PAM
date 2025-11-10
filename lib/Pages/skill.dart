import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:final_project/database/databasehelper.dart';
import 'dart:convert';

class SkillPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onDataUpdated;

  const SkillPage({super.key, required this.userData, this.onDataUpdated});

  @override
  State<SkillPage> createState() => _SkillPageState();
}

class _SkillPageState extends State<SkillPage> {
  Map<String, dynamic>? userData;
  List<double> quizScores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final db = DatabaseHelper.instance;
      final user = await db.getUserById(widget.userData['id']);

      if (user != null) {
        final scoreHistory = jsonDecode(user['score_history'] ?? '[]') as List;
        final scores = scoreHistory.map<double>((score) {
          if (score is int) return score.toDouble();
          if (score is double) return score;
          return 0.0;
        }).toList();

        setState(() {
          userData = user;
          quizScores = scores;
          isLoading = false;
        });
      } else {
        setState(() {
          userData = widget.userData;
          quizScores = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        userData = widget.userData;
        quizScores = [];
        isLoading = false;
      });
    }
  }

  // ✅ PERBAIKAN: Level naik setiap 10 XP, dimulai dari Level 1
  int get userLevel {
    final xp = userData?['xp'] ?? 0;
    return (xp ~/ 10) + 1; // Level 1: 0-9 XP, Level 2: 10-19 XP, dst.
  }

  // ✅ PERBAIKAN: Progress berdasarkan XP di level saat ini
  double get levelProgress {
    final xp = userData?['xp'] ?? 0;
    final xpInCurrentLevel = xp % 10; // XP di level saat ini (0-9)
    return xpInCurrentLevel / 10.0; // Convert ke range 0.0 - 1.0
  }

  // ✅ PERBAIKAN: XP menuju level berikutnya
  int get xpToNextLevel {
    final xp = userData?['xp'] ?? 0;
    final xpNum = xp is int ? xp : (xp as num).toInt();
    return 10 - (xpNum % 10);
  }

  // ✅ XP di level saat ini (untuk display)
  int get currentLevelXP {
    final xp = userData?['xp'] ?? 0;
    return xp % 10;
  }

  // ✅ XP minimum untuk level saat ini
  int get minXPForCurrentLevel {
    final xp = userData?['xp'] ?? 0;
    return (userLevel - 1) * 10;
  }

  // ✅ XP maksimum untuk level saat ini
  int get maxXPForCurrentLevel {
    return userLevel * 10;
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _loadUserData();
    widget.onDataUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(
          child: CircularProgressIndicator(color: Colors.lightBlueAccent),
        ),
      );
    }

    if (userData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(
          child: Text(
            'Data pengguna tidak ditemukan',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final currentXP = (userData!['xp'] ?? 0).toDouble();

    final allSpots = List.generate(
      quizScores.length,
      (index) => FlSpot((index + 1).toDouble(), quizScores[index] * 10),
    );

    final averageScore = quizScores.isEmpty
        ? 0
        : quizScores.reduce((a, b) => a + b) / quizScores.length;
    final highestScore = quizScores.isEmpty
        ? 0
        : quizScores.reduce((a, b) => a > b ? a : b);
    final totalQuizzes = quizScores.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Level $userLevel", // ✅ Sekarang 16 XP = Level 2
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "${currentXP.toInt()} XP", // ✅ Total XP: 16
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.lightBlueAccent,
                    ),
                    onPressed: _refreshData,
                    tooltip: 'Refresh Data',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ✅ XP Progress Card - DIPERBAIKI
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Level $userLevel",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Level ${userLevel + 1}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: levelProgress, // ✅ 16 XP = 6/10 = 0.6
                        minHeight: 12,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          levelProgress > 0.7
                              ? Colors.greenAccent
                              : Colors.lightBlueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$currentLevelXP/10 XP", // ✅ 6/10 XP (benar)
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "$xpToNextLevel XP menuju Level ${userLevel + 1}", // ✅ 4 XP menuju Level 3
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // ✅ Info tambahan untuk debugging
                    const SizedBox(height: 8),
                    Text(
                      "Range Level $userLevel: $minXPForCurrentLevel - ${maxXPForCurrentLevel - 1} XP",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Progress Nilai Quiz",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (quizScores.isNotEmpty)
                    Text(
                      "Total: $totalQuizzes quiz",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Grafik
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B263B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: quizScores.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.analytics_outlined,
                              color: Colors.white54,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Belum ada riwayat quiz.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Selesaikan quiz untuk melihat progress Anda",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 100,
                            minX: 0.5,
                            maxX: quizScores.length > 1
                                ? quizScores.length + 0.5
                                : 1.5,
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: quizScores.length > 10 ? 2 : 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value >= 1 &&
                                        value <= quizScores.length &&
                                        value == value.toInt()) {
                                      return Text(
                                        "Q${value.toInt()}",
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 20,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: Colors.lightBlueAccent,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: Colors.lightBlueAccent,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.lightBlueAccent.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                spots: allSpots,
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // Stats Summary
              if (quizScores.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B263B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        "Rata-rata",
                        "${(averageScore * 10).toInt()}",
                        Icons.trending_up,
                        Colors.greenAccent,
                      ),
                      _buildStatItem(
                        "Tertinggi",
                        "${(highestScore * 10).toInt()}",
                        Icons.emoji_events,
                        Colors.amber,
                      ),
                      _buildStatItem(
                        "Total Quiz",
                        "$totalQuizzes",
                        Icons.quiz,
                        Colors.lightBlueAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

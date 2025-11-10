import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:final_project/Pages/Homepage.dart';
import 'package:final_project/database/databasehelper.dart';

class CurrencyQuizPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CurrencyQuizPage({super.key, required this.userData});

  @override
  State<CurrencyQuizPage> createState() => _CurrencyQuizPageState();
}

class _CurrencyQuizPageState extends State<CurrencyQuizPage> {
  List countries = [];
  List<List<String>> questionOptions = [];
  int currentQuestion = 0;
  int selectedAnswer = 0;
  bool answered = false;
  int score = 0;
  final db = DatabaseHelper.instance;
  bool _isSaving = false;
  List<bool> correctAnswers = []; // Track jawaban benar per soal

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    const url =
        'https://restcountries.com/v3.1/all?fields=name,currencies,flags';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        // Ambil hanya negara yang memiliki data mata uang
        data = data
            .where(
              (c) =>
                  c['currencies'] != null &&
                  c['currencies'].isNotEmpty &&
                  c['flags'] != null &&
                  c['flags']['png'] != null,
            )
            .toList();

        data.shuffle();
        setState(() {
          countries = data.take(10).toList();
          correctAnswers = List.filled(
            10,
            false,
          ); // Initialize correct answers tracker
          _generateOptions();
        });
      } else {
        throw Exception('Gagal memuat data negara');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _generateOptions() {
    questionOptions = countries.map((country) {
      String correctCurrency = country['currencies'].values.first['name'];
      List<String> opts = [correctCurrency];

      while (opts.length < 4) {
        String randomCurrency =
            countries[(countries.indexOf(country) + opts.length) %
                    countries.length]['currencies']
                .values
                .first['name'];
        if (!opts.contains(randomCurrency)) opts.add(randomCurrency);
      }

      opts.shuffle();
      return opts;
    }).toList();
  }

  // METHOD UNTUK UPDATE XP KE DATABASE
  Future<void> _updateXPForCorrectAnswer() async {
    try {
      final userId = widget.userData['id'];
      if (userId != null) {
        // Dapatkan XP saat ini
        final currentUser = await db.getUserById(userId);
        final currentXP = currentUser?['xp'] ?? 0;

        // Tambah 2 XP untuk jawaban benar
        final newXP = currentXP + 2;

        // Update XP di database
        await db.updateXP(userId, newXP);

        print('✅ +2 XP! Total XP sekarang: $newXP');
      }
    } catch (e) {
      print('❌ Error updating XP: $e');
    }
  }

  // METHOD UNTUK SIMPAN HASIL QUIZ KE DATABASE
  Future<void> _saveQuizResults() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = widget.userData['id'];
      if (userId != null) {
        // Hitung total XP yang didapat (score × 2)
        final xpEarned = score * 2;

        // Simpan score ke history
        await db.addScoreToHistory(userId, score);

        print(
          '✅ Currency Quiz completed! Score: $score/${countries.length}, XP earned: $xpEarned',
        );

        // Tampilkan dialog hasil
        _showResultDialog(score, xpEarned);
      } else {
        throw Exception('User ID tidak ditemukan');
      }
    } catch (e) {
      print('❌ Error saving quiz results: $e');
      _showErrorDialog();
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void nextQuestion() {
    if (currentQuestion < countries.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = 0;
        answered = false;
      });
    } else {
      _saveQuizResults();
    }
  }

  void _showResultDialog(int finalScore, int xpEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(
          "Kuis Mata Uang Selesai! 🎉",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Skor Akhir: $finalScore/${countries.length}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "XP Didapat: +$xpEarned XP",
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Setiap jawaban benar = 2 XP",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetAndGoHome();
            },
            child: const Text("Kembali ke Menu Utama"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: const Text("Gagal menyimpan hasil quiz. Coba lagi nanti."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetAndGoHome();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _resetAndGoHome() {
    // Reset state
    setState(() {
      currentQuestion = 0;
      selectedAnswer = 0;
      answered = false;
      score = 0;
      _isSaving = false;
      correctAnswers = List.filled(10, false);
      countries.shuffle();
      _generateOptions();
    });

    // Kembali ke homepage dengan userData
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Homepage(userData: widget.userData),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (countries.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1E61),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final question = countries[currentQuestion];
    final countryName = question['name']['common'];
    final correctAnswer = question['currencies'].values.first['name'];
    final options = questionOptions[currentQuestion];
    final flagUrl = question['flags']['png'];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1E61),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan progress dan XP info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${currentQuestion + 1}/${countries.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Score: $score • XP: +${score * 2}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "💰",
                    style: TextStyle(fontSize: 22, color: Colors.white70),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                "Apa mata uang yang digunakan oleh negara ini?",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 24),

              // Gambar bendera
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    flagUrl,
                    width: 200,
                    height: 130,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 200,
                        height: 130,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.flag, color: Colors.white, size: 100),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  countryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Pilihan jawaban
              for (int i = 0; i < options.length; i++)
                _answerOption(i + 1, options[i], correctAnswer),

              const Spacer(),

              // Loading indicator jika sedang menyimpan
              if (_isSaving) ...[
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        "Menyimpan hasil...",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Tombol Next/Finish
              Center(
                child: ElevatedButton(
                  onPressed: answered && !_isSaving ? nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: answered && !_isSaving
                        ? const Color(0xFF0066FF)
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    currentQuestion == countries.length - 1
                        ? "Finish Quiz"
                        : "Next Question",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _answerOption(int index, String text, String correctAnswer) {
    bool isSelected = selectedAnswer == index;
    bool isCorrect = text == correctAnswer;

    Color borderColor = Colors.white24;
    Color fillColor = const Color(0xFF2B2F80);
    IconData? icon;
    Color? iconColor;

    if (answered) {
      if (isCorrect) {
        borderColor = Colors.green;
        fillColor = Colors.green.withOpacity(0.3);
        icon = Icons.check_circle;
        iconColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        borderColor = Colors.red;
        fillColor = Colors.red.withOpacity(0.3);
        icon = Icons.cancel;
        iconColor = Colors.red;
      }
    }

    return GestureDetector(
      onTap: answered || _isSaving
          ? null
          : () async {
              setState(() {
                selectedAnswer = index;
                answered = true;

                if (text == correctAnswer) {
                  score++;
                  correctAnswers[currentQuestion] = true;

                  // UPDATE XP KE DATABASE SETIAP JAWABAN BENAR
                  _updateXPForCorrectAnswer();
                }
              });
            },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Text(
              "$index.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (icon != null) Icon(icon, color: iconColor),
          ],
        ),
      ),
    );
  }
}

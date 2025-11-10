import 'package:flutter/material.dart';
import 'package:final_project/animation/animation.dart';
import 'package:final_project/animation/animation2.dart';
import 'Homepage.dart';
import 'package:final_project/database/databasehelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'registerpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isHovering = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  final db = DatabaseHelper.instance;

  // Session keys
  static const String _sessionKey = 'user_session';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  // 1. Mengecek Session yang ada
  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSession = prefs.getBool(_sessionKey) ?? false;

    if (hasSession) {
      final username = prefs.getString(_usernameKey);
      final userId = prefs.getInt(_userIdKey);

      if (username != null && userId != null) {
        // Ambil data user terbaru dari database
        final user = await db.getUserById(userId);
        if (user != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage(userData: user)),
          );
        }
      }
    }
  }

  // SIMPAN SESSION
  Future<void> _saveSession(int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, true);
    await prefs.setString(_usernameKey, username);
    await prefs.setInt(_userIdKey, userId);
  }

  // HAPUS SESSION
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
  }

  // 2. Proses Login
  Future<void> login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Username dan Password harus diisi!",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await db.loginUser(username, password);

      if (user != null) {
        // Menyimpan Session
        await _saveSession(user['id'], username);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Login Berhasil", textAlign: TextAlign.center),
          ),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage(userData: user)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Username atau Password salah",
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Terjadi kesalahan: ${e.toString()}",
            textAlign: TextAlign.center,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Lempar ke register
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeSlideDownAnimation(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/loginbg1.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: -80,
                    bottom: 120,
                    width: 300,
                    height: 200,
                    child: SlideLeftRightLoop(
                      child: Image.asset('assets/images/awan.png'),
                    ),
                  ),
                  Positioned(
                    left: 260,
                    bottom: 80,
                    width: 280,
                    height: 190,
                    child: SlideLeftRightLoop(
                      child: Image.asset('assets/images/awan.png'),
                    ),
                  ),
                ],
              ),
            ),

            // Form Login
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input Box
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF2DDBE6),
                          blurRadius: 10,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Masukkan Username',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color(0xFF2DDBE6),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Masukkan Password',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFF2DDBE6),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Tombol Login
                  GestureDetector(
                    onTapDown: (_) => setState(() => _isHovering = true),
                    onTapUp: (_) => setState(() => _isHovering = false),
                    onTapCancel: () => setState(() => _isHovering = false),
                    onTap: _isLoading ? null : login,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: _isLoading
                            ? const LinearGradient(
                                colors: [Colors.grey, Colors.grey],
                              )
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF2DDBE6),
                                  Colors.lightBlueAccent,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: _isHovering && !_isLoading
                            ? [
                                const BoxShadow(
                                  color: Colors.orange,
                                  blurRadius: 40,
                                  offset: Offset(0, 10),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider dengan text "ATAU"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey[400], thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "ATAU",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey[400], thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tombol Daftar Sekarang
                  GestureDetector(
                    onTap: _navigateToRegister,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF2DDBE6),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Daftar Sekarang",
                          style: TextStyle(
                            color: Color(0xFF2DDBE6),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
            const Text(
              "PT. DanielEducation ©️2025",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:final_project/animation/animation.dart';
import 'package:final_project/animation/animation2.dart';
import 'package:final_project/database/databasehelper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isHovering = false;
  bool _isLoading = false;
  final db = DatabaseHelper.instance;

  // Fungsi Register
  Future<void> register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validasi input
    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Semua field harus diisi!",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Password dan Konfirmasi Password tidak sama!",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Password minimal 6 karakter!",
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Username minimal 3 karakter!",
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
      final existingUser = await db.getUserByUsername(username);
      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Username sudah terdaftar!",
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      }
     
      final result = await db.registerUser(username, password);

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registrasi berhasil! Silakan login.",
              textAlign: TextAlign.center,
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Gagal melakukan registrasi!",
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeSlideDownAnimation(
        child: Column(
          children: <Widget>[
            // Gambar atas (awan, latar) - sama dengan login page
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

            // Form Register
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Daftar Akun Baru",
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
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
                            hintText: 'Buat Username',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Buat Password',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Konfirmasi Password',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Informasi requirements
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Requirements:",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          "• Username minimal 3 karakter\n• Password minimal 6 karakter\n• Password akan dienkripsi dengan SHA-256",
                          style: TextStyle(color: Colors.blue, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Register
                  GestureDetector(
                    onTapDown: (_) => setState(() => _isHovering = true),
                    onTapUp: (_) => setState(() => _isHovering = false),
                    onTapCancel: () => setState(() => _isHovering = false),
                    onTap: _isLoading ? null : register,
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
                                "Daftar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text("Sudah punya akun? Login di sini"),
                  ),
                ],
              ),
            ),

            const Spacer(),
            const Text("PT. DanielEducation ©️2025"),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

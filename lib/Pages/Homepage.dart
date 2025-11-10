import 'package:carousel_slider/carousel_slider.dart';
import 'package:final_project/Pages/HomepageContent.dart';
import 'package:final_project/Pages/profilepage.dart';
import 'package:final_project/Pages/skill.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/database/databasehelper.dart';

class Homepage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const Homepage({super.key, this.userData});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 1;
  final CarouselSliderController _controller = CarouselSliderController();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final db = DatabaseHelper.instance;

  // Session keys
  static const String _sessionKey = 'user_session';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';

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

  final List<IconData> _icons = [
    Icons.emoji_events_sharp,
    Icons.home_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = ["Skill Point", "Home", "Profile"];

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  // Menginisialisasi dari session
  Future<void> _initializeUserData() async {
    if (widget.userData != null) {
      setState(() {
        _userData = widget.userData;
        _isLoading = false;
      });
      return;
    }

    // Jika tidak, coba ambil dari session
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool hasSession = prefs.getBool(_sessionKey) ?? false;

      if (hasSession) {
        final String? username = prefs.getString(_usernameKey);
        final int? userId = prefs.getInt(_userIdKey);

        if (username != null && userId != null) {
          // Ambil data user terbaru dari database
          final Map<String, dynamic>? user = await db.getUserById(userId);
          if (user != null && mounted) {
            setState(() {
              _userData = user;
              _isLoading = false;
            });
            return;
          }
        }
      }

      // Jika tidak ada session, redirect ke login
      if (mounted) {
        _redirectToLogin();
      }
    } catch (e) {
      print('Error initializing user data: $e');
      if (mounted) {
        _redirectToLogin();
      }
    }
  }

  // REDIRECT KE LOGIN PAGE
  void _redirectToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // LOGOUT FUNCTION
  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // REFRESH USER DATA DARI DATABASE
  Future<void> _refreshUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt(_userIdKey);

      if (userId != null) {
        final Map<String, dynamic>? user = await db.getUserById(userId);
        if (user != null && mounted) {
          setState(() {
            _userData = user;
          });
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
              SizedBox(height: 20),
              Text(
                "Memuat data...",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_userData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 20),
              Text(
                "Terjadi kesalahan",
                style: TextStyle(color: Colors.grey[600], fontSize: 18),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _redirectToLogin,
                child: Text("Kembali ke Login"),
              ),
            ],
          ),
        ),
      );
    }

    final user = _userData!;
    return Scaffold(
      backgroundColor: Colors.white,

      // === BODY ===
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            SkillPage(userData: user, onDataUpdated: _refreshUserData),
            HomePageContent(userData: user, onDataUpdated: _refreshUserData),
            ProfilePage(
              userData: user,
              onDataUpdated: _refreshUserData,
              onLogout: _logout,
            ),
          ],
        ),
      ),

      // === BOTTOM NAVIGATION BAR ===
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            bool isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent.withOpacity(0.1) : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icons[index],
                      color: isSelected ? Colors.blueAccent : Colors.grey,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[index],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.grey[600],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

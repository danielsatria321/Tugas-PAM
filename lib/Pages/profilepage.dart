import 'package:final_project/Pages/kesanpesan.dart';
import 'package:final_project/Pages/membership.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onDataUpdated; // Tambahkan parameter ini
  final VoidCallback? onLogout; // Tambahkan parameter ini

  const ProfilePage({
    super.key,
    required this.userData,
    this.onDataUpdated, // Tambahkan di constructor
    this.onLogout, // Tambahkan di constructor
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool darkMode = false;

  // METHOD UNTUK REFRESH DATA
  Future<void> _refreshData() async {
    // Panggil callback untuk memberitahu Homepage bahwa data perlu diupdate
    widget.onDataUpdated?.call();
  }

  // METHOD KETIKA MEMBERSHIP BERUBAH
  void _onMembershipUpdated() {
    // Refresh data untuk menampilkan perubahan membership
    _refreshData();

    // Tampilkan feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Status membership berhasil diupdate!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // METHOD KETIKA XP BERUBAH
  void _onXPUpdated() {
    _refreshData();
  }

  // METHOD UNTUK LOGOUT
  Future<void> _performLogout() async {
    // Panggil callback logout dari Homepage
    widget.onLogout?.call();

    // Atau jika tidak ada callback, lakukan logout manual
    if (widget.onLogout == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xFFD6CCFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Foto profil dengan refresh indicator
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.refresh, size: 18),
                            onPressed: _refreshData,
                            tooltip: 'Refresh Profile',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user['name'] ?? user['username'] ?? "Rita Smith",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Display XP dengan animasi
                  GestureDetector(
                    onTap: _refreshData,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "${user['xp'] ?? 0} XP",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Informasi kontak
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _InfoRow(title: "Username", value: user['username'] ?? "N/A"),
                  const SizedBox(height: 8),
                  _InfoRow(
                    title: "Membership",
                    value: _getMembershipStatus(
                      user['subscription_status'] ?? 'free',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    title: "Level",
                    value: "Level ${((user['xp'] ?? 0) / 400).floor()}",
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(title: "Total Quiz", value: _getTotalQuizzes(user)),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Divider(thickness: 1, color: Colors.black12),

            // Tombol pengaturan
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _refreshData();
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Dark Mode

                    // Membership
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriptionPage(
                              userData: user,
                              onMembershipUpdated: _onMembershipUpdated,
                            ),
                          ),
                        ).then((value) {
                          // Callback ketika kembali dari membership page
                          if (value == true) {
                            _onMembershipUpdated();
                          }
                        });
                      },
                      leading: Icon(
                        Icons.shopify_rounded,
                        color: user['subscription_status'] == 'premium'
                            ? Colors.amber
                            : Colors.grey,
                      ),
                      title: Text(
                        user['subscription_status'] == 'premium'
                            ? "Premium Member"
                            : "Buy Membership",
                        style: TextStyle(
                          fontWeight: user['subscription_status'] == 'premium'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: user['subscription_status'] == 'premium'
                              ? Colors.amber
                              : Colors.black87,
                        ),
                      ),
                      trailing: user['subscription_status'] == 'premium'
                          ? const Icon(Icons.verified, color: Colors.amber)
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    const Divider(),

                    // Kesan Pesan
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text("Kesan Pesan PAM"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InformationPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(),

                    // Logout
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        "Log out",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),

                    // Refresh Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Refresh Data"),
                        onPressed: _refreshData,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMembershipStatus(String status) {
    switch (status) {
      case 'premium':
        return 'Premium Member';
      case 'free':
        return 'Free Member';
      default:
        return 'Free Member';
    }
  }

  String _getTotalQuizzes(Map<String, dynamic> user) {
    try {
      final scoreHistory = user['score_history'];
      if (scoreHistory != null && scoreHistory is String) {
        final List<dynamic> scores = jsonDecode(scoreHistory);
        return scores.length.toString();
      }
      return "0";
    } catch (e) {
      return "0";
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showStatistics(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Statistik Belajar"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem("Total XP", "${widget.userData['xp'] ?? 0}"),
              _buildStatItem(
                "Level",
                "Level ${((widget.userData['xp'] ?? 0) / 400).floor()}",
              ),
              _buildStatItem(
                "Status",
                _getMembershipStatus(
                  widget.userData['subscription_status'] ?? 'free',
                ),
              ),
              _buildStatItem("Total Quiz", _getTotalQuizzes(widget.userData)),
              _buildStatItem("Bergabung", "Recently"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showResetProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Progress"),
          content: const Text(
            "Ini hanya untuk testing. Reset progress akan mengembalikan XP ke 0 dan menghapus history quiz.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Di sini Anda bisa menambahkan logika reset progress
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.orange,
                    content: Text('Fitur reset progress dalam pengembangan'),
                  ),
                );
              },
              child: const Text(
                "Reset",
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$title: ",
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: title == "Membership" && value == "Premium Member"
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

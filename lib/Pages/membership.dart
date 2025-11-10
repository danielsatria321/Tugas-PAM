import 'package:flutter/material.dart';
import 'package:final_project/database/databasehelper.dart';

class SubscriptionPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onMembershipUpdated;

  const SubscriptionPage({
    super.key,
    required this.userData,
    this.onMembershipUpdated,
  });

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final db = DatabaseHelper.instance;
  bool _isLoading = false;
  String? _currentOperation;

  // Variabel untuk negara dan kurs
  String _selectedCountry = 'Indonesia';
  String _selectedCurrency = 'IDR';
  double _conversionRate = 1.0;
  final Map<String, double> _currencyRates = {
    'IDR': 1.0, // Indonesia - Rupiah
    'USD': 0.000064, // Amerika - USD
    'EUR': 0.000059, // Eropa - Euro
    'GBP': 0.000051, // Inggris - Pound
    'JPY': 0.0096, // Jepang - Yen
    'SGD': 0.000086, // Singapura - Dollar
    'MYR': 0.00030, // Malaysia - Ringgit
    'AUD': 0.000097, // Australia - Dollar
  };

  final Map<String, String> _countryCurrencyMap = {
    'Indonesia': 'IDR',
    'Amerika Serikat': 'USD',
    'Eropa': 'EUR',
    'Inggris': 'GBP',
    'Jepang': 'JPY',
    'Singapura': 'SGD',
    'Malaysia': 'MYR',
    'Australia': 'AUD',
  };

  // Variabel untuk pencarian
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _filteredCountries = _countryCurrencyMap.keys.toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUserPreferences() {
    // Load preferensi user dari database atau gunakan default
    // Di sini kita gunakan Indonesia sebagai default
    setState(() {
      _selectedCountry = 'Indonesia';
      _selectedCurrency = 'IDR';
      _conversionRate = _currencyRates[_selectedCurrency] ?? 1.0;
    });
  }

  // Method untuk filter negara berdasarkan pencarian
  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _countryCurrencyMap.keys.toList();
      } else {
        _filteredCountries = _countryCurrencyMap.keys
            .where(
              (country) => country.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  // Method untuk menghitung harga berdasarkan kurs
  String _getConvertedPrice(double basePriceIDR) {
    final convertedPrice = basePriceIDR * _conversionRate;

    switch (_selectedCurrency) {
      case 'IDR':
        return 'Rp ${(convertedPrice).toStringAsFixed(0)}';
      case 'USD':
        return '\$${convertedPrice.toStringAsFixed(2)}';
      case 'EUR':
        return '€${convertedPrice.toStringAsFixed(2)}';
      case 'GBP':
        return '£${convertedPrice.toStringAsFixed(2)}';
      case 'JPY':
        return '¥${convertedPrice.toStringAsFixed(0)}';
      case 'SGD':
        return 'S\$${convertedPrice.toStringAsFixed(2)}';
      case 'MYR':
        return 'RM ${convertedPrice.toStringAsFixed(2)}';
      case 'AUD':
        return 'A\$${convertedPrice.toStringAsFixed(2)}';
      default:
        return 'Rp ${basePriceIDR.toStringAsFixed(0)}';
    }
  }

  // Method untuk mendapatkan simbol mata uang
  String _getCurrencySymbol() {
    switch (_selectedCurrency) {
      case 'IDR':
        return 'Rp';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'SGD':
        return 'S\$';
      case 'MYR':
        return 'RM';
      case 'AUD':
        return 'A\$';
      default:
        return 'Rp';
    }
  }

  // Method untuk mendapatkan waktu pembaruan dalam zona waktu yang dipilih
  String _getMembershipUpdateTime() {
    final now = DateTime.now().toUtc();

    // Simulasi zona waktu berdasarkan negara (dalam praktik nyata, gunakan package timezone)
    final timezoneOffset = _getTimezoneOffset();
    final localTime = now.add(timezoneOffset);

    // Format tanggal dan waktu
    final formattedDate =
        '${localTime.day}/${localTime.month}/${localTime.year}';
    final formattedTime =
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

    return '$formattedTime, $formattedDate';
  }

  // Simulasi offset zona waktu berdasarkan negara
  Duration _getTimezoneOffset() {
    switch (_selectedCountry) {
      case 'Amerika Serikat':
        return const Duration(hours: -5); // EST (UTC-5)
      case 'Eropa':
        return const Duration(hours: 1); // CET (UTC+1)
      case 'Inggris':
        return const Duration(hours: 0); // GMT (UTC+0)
      case 'Jepang':
        return const Duration(hours: 9); // JST (UTC+9)
      case 'Singapura':
        return const Duration(hours: 8); // SGT (UTC+8)
      case 'Malaysia':
        return const Duration(hours: 8); // MYT (UTC+8)
      case 'Australia':
        return const Duration(hours: 10); // AEST (UTC+10)
      case 'Indonesia':
      default:
        return const Duration(hours: 7); // WIB (UTC+7)
    }
  }

  Future<void> _upgradeToPremium() async {
    setState(() {
      _isLoading = true;
      _currentOperation = 'upgrade';
    });

    try {
      final userId = widget.userData['id'];
      if (userId != null) {
        print(' Starting premium upgrade for user: $userId');

        await db.updateSubscription(userId, 'premium');

        // Debug: print updated user data
        final updatedUser = await db.getUserById(userId);
        print(
          'Premium upgrade successful. New status: ${updatedUser?['subscription_status']}',
        );

        // Panggil callback untuk update data
        widget.onMembershipUpdated?.call();

        // Kembali dengan value true untuk indicate perubahan
        if (mounted) {
          Navigator.pop(context, true);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('🎉 Berhasil upgrade ke Premium!'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('User ID tidak ditemukan');
      }
    } catch (e) {
      print('❌ Upgrade error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Gagal upgrade: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentOperation = null;
        });
      }
    }
  }

  Future<void> _downgradeToFree() async {
    setState(() {
      _isLoading = true;
      _currentOperation = 'downgrade';
    });

    try {
      final userId = widget.userData['id'];
      if (userId != null) {
        print('🎯 Starting downgrade to free for user: $userId');

        await db.updateSubscription(userId, 'free');

        // Debug: print updated user data
        final updatedUser = await db.getUserById(userId);
        print(
          '✅ Downgrade successful. New status: ${updatedUser?['subscription_status']}',
        );

        // Panggil callback untuk update data
        widget.onMembershipUpdated?.call();

        // Kembali dengan value true untuk indicate perubahan
        if (mounted) {
          Navigator.pop(context, true);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blue,
            content: Text('✅ Berhasil downgrade ke Free'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('User ID tidak ditemukan');
      }
    } catch (e) {
      print('❌ Downgrade error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Gagal downgrade: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentOperation = null;
        });
      }
    }
  }

  void _showCountrySelectionDialog() {
    // Reset pencarian saat dialog dibuka
    _searchController.clear();
    _filteredCountries = _countryCurrencyMap.keys.toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Negara Anda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Cari negara...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (query) {
                                setDialogState(() {
                                  if (query.isEmpty) {
                                    _filteredCountries = _countryCurrencyMap
                                        .keys
                                        .toList();
                                  } else {
                                    _filteredCountries = _countryCurrencyMap
                                        .keys
                                        .where(
                                          (country) => country
                                              .toLowerCase()
                                              .contains(query.toLowerCase()),
                                        )
                                        .toList();
                                  }
                                });
                              },
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setDialogState(() {
                                  _searchController.clear();
                                  _filteredCountries = _countryCurrencyMap.keys
                                      .toList();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Info jumlah hasil
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _filteredCountries.isEmpty
                            ? 'Tidak ada negara ditemukan'
                            : '${_filteredCountries.length} negara ditemukan',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // List Negara
                    Expanded(
                      child: _filteredCountries.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Negara tidak ditemukan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Coba dengan kata kunci lain',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredCountries.length,
                              itemBuilder: (context, index) {
                                final country = _filteredCountries[index];
                                final currency = _countryCurrencyMap[country]!;

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  elevation: 1,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color: _selectedCountry == country
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    title: Text(
                                      country,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      'Mata uang: $currency',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: _selectedCountry == country
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        _selectedCountry = country;
                                        _selectedCurrency = currency;
                                        _conversionRate =
                                            _currencyRates[currency] ?? 1.0;
                                      });
                                      Navigator.of(context).pop();

                                      // Tampilkan snackbar konfirmasi
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.blue,
                                          content: Text(
                                            'Negara diubah ke $country ($currency)',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(bool isUpgrade) {
    final basePrice = 50000.0; // Harga dasar dalam IDR
    final convertedPrice = _getConvertedPrice(basePrice);
    final currencySymbol = _getCurrencySymbol();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isUpgrade ? 'Upgrade ke Premium?' : 'Downgrade ke Free?',
            style: TextStyle(
              color: isUpgrade ? Colors.amber[700] : Colors.blue[700],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUpgrade
                    ? 'Anda akan mengupgrade ke Premium dengan harga $convertedPrice/bulan. Nikmati akses penuh ke semua fitur!'
                    : 'Anda akan kembali ke Free plan. Beberapa fitur premium akan terbatas.',
              ),
              if (isUpgrade) ...[
                const SizedBox(height: 8),
                Text(
                  'Negara: $_selectedCountry',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Mata uang: $_selectedCurrency',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isUpgrade) {
                  _upgradeToPremium();
                } else {
                  _downgradeToFree();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isUpgrade
                    ? Colors.amber[700]
                    : Colors.blue[700],
              ),
              child: Text(
                isUpgrade ? 'Ya, Upgrade' : 'Ya, Downgrade',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = widget.userData['subscription_status'] == 'premium';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Membership',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        actions: [
          // Tombol pilih negara
          IconButton(
            icon: const Icon(Icons.public),
            onPressed: _showCountrySelectionDialog,
            tooltip: 'Pilih Negara',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Negara Terpilih
                    _buildCountryInfoCard(),

                    const SizedBox(height: 16),

                    // Status Saat Ini
                    _buildCurrentStatusCard(isPremium),

                    const SizedBox(height: 24),

                    // Pilihan Membership
                    const Text(
                      'Pilihan Membership',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih plan yang sesuai dengan kebutuhan Anda',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    // Free Plan
                    _buildPlanCard(
                      title: 'Free Plan',
                      price: 'Gratis',
                      features: const [
                        'Akses quiz terbatas',
                        'Basic features',
                        'Iklan tersedia',
                        'Support standar',
                      ],
                      isCurrent: !isPremium,
                      isPremium: false,
                      onTap: isPremium
                          ? () => _showConfirmationDialog(false)
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Premium Plan
                    _buildPlanCard(
                      title: 'Premium Plan',
                      price:
                          '${_getConvertedPrice(50000)}/bulan', // Rp 50,000 dalam IDR
                      features: const [
                        'Akses semua quiz tanpa batas',
                        'Fitur premium lengkap',
                        'Tanpa iklan',
                        'Priority support 24/7',
                        'Bonus XP 2x lipat',
                        'Statistik detail',
                      ],
                      isCurrent: isPremium,
                      isPremium: true,
                      onTap: !isPremium
                          ? () => _showConfirmationDialog(true)
                          : null,
                    ),

                    const SizedBox(height: 32),

                    const SizedBox(height: 32),

                    // FAQ Section
                    _buildFAQSection(),

                    const SizedBox(height: 24),

                    // Info Footer
                    _buildSecurityFooter(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCountryInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.public, color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi & Mata Uang',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    '$_selectedCountry • $_selectedCurrency',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _showCountrySelectionDialog,
              child: const Text('Ubah'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _currentOperation == 'upgrade'
                ? 'Mengupgrade ke Premium...'
                : 'Downgrade ke Free...',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Harap tunggu sebentar',
            style: TextStyle(fontSize: 14, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard(bool isPremium) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isPremium ? Colors.amber[50] : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPremium ? Colors.amber[100] : Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPremium ? Icons.verified : Icons.person_outline,
                    color: isPremium ? Colors.amber[700] : Colors.blue[700],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPremium ? 'Premium Member' : 'Free Member',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPremium
                              ? Colors.amber[700]
                              : Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPremium
                            ? 'Anda menikmati semua fitur premium 🎉'
                            : 'Upgrade untuk akses penuh ke semua fitur',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Tampilkan info pembaruan membership jika premium
            if (isPremium) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.update, color: Colors.green[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Membership diperbarui pada ${_getMembershipUpdateTime()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required bool isCurrent,
    required bool isPremium,
    required VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCurrent
              ? (isPremium ? Colors.amber : Colors.blue)
              : Colors.grey[300]!,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPremium ? Colors.amber[700] : Colors.blue[700],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isPremium ? Colors.amber : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'AKTIF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ...features.map((feature) => _buildFeatureItem(feature)),
            const SizedBox(height: 24),
            if (onTap != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPremium
                        ? Colors.amber[700]
                        : Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    isPremium ? 'UPGRADE KE PREMIUM' : 'PILIH FREE PLAN',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: isCurrent
                          ? (isPremium ? Colors.amber : Colors.blue)
                          : Colors.grey[400]!,
                    ),
                  ),
                  child: Text(
                    isCurrent ? 'SEDANG AKTIF' : 'TIDAK TERSEDIA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCurrent
                          ? (isPremium ? Colors.amber[700] : Colors.blue[700])
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(feature, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pertanyaan Umum',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'Bagaimana cara pembayaran?',
          'Pembayaran dapat dilakukan melalui transfer bank, kartu kredit, debit, atau e-wallet. Proses instan dan aman.',
        ),
        _buildFAQItem(
          'Bisa dibatalkan kapan saja?',
          'Ya! Anda bisa membatalkan kapan saja. Membership akan tetap aktif hingga periode berakhir.',
        ),
        _buildFAQItem(
          'Apakah harga berubah berdasarkan negara?',
          'Ya, harga akan dikonversi otomatis berdasarkan mata uang negara yang Anda pilih.',
        ),
        _buildFAQItem(
          'Apakah data saya aman?',
          'Sangat aman! Data dan pembayaran Anda dienkripsi dengan teknologi keamanan tingkat tinggi.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.security, color: Colors.green, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Pembayaran 100% Aman & Terenkripsi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Data dan transaksi Anda terjamin dan dilindungi ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.green, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSecurityIcon(Icons.credit_card),
              const SizedBox(width: 20),
              _buildSecurityIcon(Icons.lock),
              const SizedBox(width: 20),
              _buildSecurityIcon(Icons.verified_user),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[100],
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.green[700], size: 24),
    );
  }
}

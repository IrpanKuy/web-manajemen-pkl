import 'package:flutter/material.dart';
import 'package:flutter_app/core/api/client/home_page_client.dart';
import 'package:flutter_app/core/api/dio_client.dart';
import 'package:flutter_app/data/models/response/auth_response.dart';
import 'package:flutter_app/data/models/response/home_page_response.dart';
import 'package:flutter_app/services/session_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _currentUser;
  final HomePageClient _homePageClient = HomePageClient(DioClient().dio);
  HomePageResponse? _homePageResponse;

  bool _isLoading = false;

  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _loadCurrentUser();
    _loadHomePageData();
    // _homePageClient = HomPageClient(DioClient().dio);

    // final HomePageResponse = _homePageClient.getHomePageData();
  }

  Future<void> _loadCurrentUser() async {
    User? user = await _sessionService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadHomePageData() async {
    try {
      final response = await _homePageClient.getHomePageData();
      setState(() {
        _homePageResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Warna background abu-abu muda
      body: SingleChildScrollView(
        // Biar background biru mentok atas (hilangkan padding bawaan OS)
        physics: const ClampingScrollPhysics(),

        child: Stack(
          children: [
            // 2. Background Biru (Sekarang ada di dalam ScrollView)
            Container(
              height: 300, // Berikan tinggi tetap (atau 35% layar)
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),

            // 3. Konten (Header, Card, dll)
            // Gunakan SafeArea di sini atau Padding manual agar tidak ketutup status bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  20, 50, 20, 20), // Top 50 biar aman dari poni HP
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Profil ---
                  _buildHeaderProfile(),

                  const SizedBox(height: 24),

                  // --- Kartu Utama ---
                  _buildActivityCard(),

                  const SizedBox(height: 24),

                  // --- Menu Grid ---
                  _buildGridMenu(),

                  const Text(
                    "STATISTIK PKL",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(),

                  const SizedBox(height: 30),
                  // ... dst
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// --- Statistik ---

  // WIDGET: Header Profil (Foto, Nama, Lokasi)
  Widget _buildHeaderProfile() {
    return Column(
      children: [
        Row(
          children: [
            // Foto Profil
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              // child: const CircleAvatar(
              //   radius: 28,
              //   backgroundImage: NetworkImage(
              //       'https://i.pravatar.cc/150?img=5'), // Placeholder image
              //   // Jika pakai aset lokal: AssetImage('assets/profile.png')
              // ),
            ),
            const SizedBox(width: 16),
            // Teks Nama & Kelas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, ${_currentUser?.name ?? 'Pengguna'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "XII RPL 1 - SMKN 1 Jakarta",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Tombol Pill (Lokasi & Pembimbing)
        Row(
          children: [
            _buildPillBadge(Icons.location_on, "PT Inovasi Teknologi"),
            const SizedBox(width: 10),
            _buildPillBadge(Icons.people, "Pembimbing: Pak Budi"),
          ],
        ),
      ],
    );
  }

  // WIDGET: Kartu Aktivitas Hari Ini
  Widget _buildActivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Judul & Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Aktivitas Hari Ini",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Selasa, 24 Okt",
                  style: TextStyle(
                    color: Color(0xFF4C4DDC),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Icon Status (Masuk, Jurnal, Keluar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem(Icons.check, Colors.green, "Absen Masuk", true),
              _buildStatusItem(Icons.edit, Colors.amber, "Jurnal", true),
              _buildStatusItem(
                  Icons.exit_to_app, Colors.grey, "Absen Keluar", false),
            ],
          ),
          const SizedBox(height: 24),
          // Tombol Kuning Besar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_square, color: Colors.black87),
              label: const Text(
                "Isi Jurnal Harian",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD600), // Warna Kuning
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Grid Menu 4 Kotak
  Widget _buildGridMenu() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1, // Mengatur rasio lebar:tinggi kartu
      children: [
        _buildMenuCard(Icons.book, "Riwayat Jurnal", "Lihat catatanmu",
            Colors.blue[50]!, Colors.blue),
        _buildMenuCard(Icons.history, "Riwayat Absensi", "Log kehadiran",
            Colors.orange[50]!, Colors.orange),
        _buildMenuCard(Icons.business, "Tempat PKL", "Info perusahaan",
            Colors.blue[50]!, Colors.blue),
        _buildMenuCard(Icons.person_pin, "Ganti Pembimbing", "Request baru",
            Colors.red[50]!, Colors.red),
      ],
    );
  }

  // WIDGET: Kartu Statistik Bawah
  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today, color: Colors.brown),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Kehadiran",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Bulan ini",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Text(
            "22",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(" Hari", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- Helper Widgets Kecil ---
  Widget _buildPillBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Helper: Icon Bulat di dalam Card Aktivitas
  Widget _buildStatusItem(
      IconData icon, Color color, String label, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green[700] : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Helper: Kartu Menu Kotak
  Widget _buildMenuCard(IconData icon, String title, String subtitle,
      Color bgIcon, Color colorIcon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgIcon,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorIcon),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

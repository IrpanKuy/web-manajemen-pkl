import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/response/home_page_response.dart';

class StatusCard extends StatelessWidget {
  final PenempatanData? penempatanData;
  final String?
      statusAbsensi; // 'absenMasuk', 'buatJurnal', 'absenPulang', 'selesai'
  final VoidCallback onAbsenMasuk;
  final VoidCallback onIsiJurnal;
  final VoidCallback onAbsenPulang;
  final bool isLoading;

  const StatusCard({
    super.key,
    required this.penempatanData,
    required this.statusAbsensi,
    required this.onAbsenMasuk,
    required this.onIsiJurnal,
    required this.onAbsenPulang,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingCard();

    // 1. Logic Warna & Text
    String title = "Menunggu";
    String subtitle = "-";
    Color themeColor = Colors.grey;
    IconData icon = Icons.hourglass_empty;
    String btnText = "Tidak Ada Aksi";
    VoidCallback? onAction;
    bool isActive = false;

    switch (statusAbsensi) {
      case 'absenMasuk':
        title = "Waktunya Masuk";
        subtitle = "Scan QR Code di lokasi magang";
        themeColor = const Color(0xFF4A60AA); // Biru
        icon = Icons.login_rounded;
        btnText = "Absen Masuk";
        onAction = onAbsenMasuk;
        isActive = true;
        break;
      case 'buatJurnal':
        title = "Isi Jurnal Harian";
        subtitle = "Catat kegiatan magangmu hari ini";
        themeColor = const Color(0xFFFF9800); // Orange
        icon = Icons.edit_note_rounded;
        btnText = "Isi Jurnal";
        onAction = onIsiJurnal;
        isActive = true;
        break;
      case 'absenPulang':
        title = "Waktunya Pulang";
        subtitle = "Selesaikan hari ini dengan absen pulang";
        themeColor = const Color(0xFFE53935); // Merah
        icon = Icons.logout_rounded;
        btnText = "Absen Keluar";
        onAction = onAbsenPulang;
        isActive = true;
        break;
      case 'selesai':
        title = "Selesai";
        subtitle = "Sampai jumpa besok!";
        themeColor = const Color(0xFF43A047); // Hijau
        icon = Icons.check_circle_rounded;
        btnText = "Sudah Selesai";
        isActive = false;
        break;
    }

    // 2. Tampilan Card
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bagian Atas: Info Status
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Icon Circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: themeColor, size: 26),
                ),
                const SizedBox(width: 16),
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Garis Pemisah Tipis
          Divider(height: 1, color: Colors.grey[100]),

          // Bagian Bawah: Tombol Aksi Full Width
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isActive ? onAction : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isActive ? icon : Icons.lock, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      btnText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

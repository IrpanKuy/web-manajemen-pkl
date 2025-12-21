import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/response/home_page_response.dart';

// =============================================================================
// STATUS CARD - Card untuk status berjalan (absensi harian)
// =============================================================================
class StatusCard extends StatefulWidget {
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
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  Timer? _countdownTimer;
  Duration _countdownDuration = Duration.zero;
  bool _canAbsenPulang = false;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  @override
  void didUpdateWidget(StatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusAbsensi != widget.statusAbsensi ||
        oldWidget.penempatanData?.mitra?.jamMasuk !=
            widget.penempatanData?.mitra?.jamMasuk) {
      _initializeCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initializeCountdown() {
    _countdownTimer?.cancel();

    final mitra = widget.penempatanData?.mitra;
    if (mitra == null) return;

    final now = DateTime.now();

    if (widget.statusAbsensi == 'absenMasuk') {
      // Countdown untuk absen masuk sebelum dinyatakan telat
      final jamMasukStr = mitra.jamMasuk;
      if (jamMasukStr != null && jamMasukStr.isNotEmpty) {
        final jamMasukParts = jamMasukStr.split(':');
        if (jamMasukParts.length >= 2) {
          final jamMasukTarget = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(jamMasukParts[0]),
            int.parse(jamMasukParts[1]),
            jamMasukParts.length > 2 ? int.parse(jamMasukParts[2]) : 0,
          );

          if (now.isBefore(jamMasukTarget)) {
            _countdownDuration = jamMasukTarget.difference(now);
            _startCountdown();
          } else {
            _countdownDuration = Duration.zero;
          }
        }
      }
    } else if (widget.statusAbsensi == 'absenPulang' ||
        widget.statusAbsensi == 'buatJurnal') {
      // Countdown untuk absen pulang (30 menit sebelum jam_pulang)
      final jamPulangStr = mitra.jamPulang;
      if (jamPulangStr != null && jamPulangStr.isNotEmpty) {
        final jamPulangParts = jamPulangStr.split(':');
        if (jamPulangParts.length >= 2) {
          final jamPulangTarget = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(jamPulangParts[0]),
            int.parse(jamPulangParts[1]),
            jamPulangParts.length > 2 ? int.parse(jamPulangParts[2]) : 0,
          );

          // 30 menit sebelum jam pulang
          final batasAbsenPulang =
              jamPulangTarget.subtract(const Duration(minutes: 30));

          if (now.isBefore(batasAbsenPulang)) {
            _countdownDuration = batasAbsenPulang.difference(now);
            _canAbsenPulang = false;
            _startCountdown();
          } else {
            _countdownDuration = Duration.zero;
            _canAbsenPulang = true;
          }
        }
      } else {
        // Tidak ada jam pulang, izinkan absen pulang
        _canAbsenPulang = true;
      }
    }

    if (mounted) setState(() {});
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownDuration.inSeconds > 0) {
        setState(() {
          _countdownDuration = _countdownDuration - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        // Re-initialize to check if absen pulang should be enabled
        _initializeCountdown();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildLoadingCard();

    // 1. Logic Warna & Text
    String title = "Menunggu";
    String subtitle = "-";
    Color themeColor = Colors.grey;
    IconData icon = Icons.hourglass_empty;
    String btnText = "Tidak Ada Aksi";
    VoidCallback? onAction;
    bool isActive = false;
    String? countdownText;
    bool showCountdown = false;

    switch (widget.statusAbsensi) {
      case 'absenMasuk':
        title = "Waktunya Masuk";
        subtitle = "Scan QR Code di lokasi magang";
        themeColor = const Color(0xFF4A60AA); // Biru
        icon = Icons.login_rounded;
        btnText = "Absen Masuk";
        onAction = widget.onAbsenMasuk;
        isActive = true;

        // Tampilkan countdown jika masih ada waktu sebelum telat
        if (_countdownDuration.inSeconds > 0) {
          countdownText =
              "Sisa waktu sebelum telat: ${_formatDuration(_countdownDuration)}";
          showCountdown = true;
        } else {
          final jamMasukStr = widget.penempatanData?.mitra?.jamMasuk;
          if (jamMasukStr != null) {
            countdownText = "⚠️ Anda sudah melewati jam masuk ($jamMasukStr)";
            showCountdown = true;
          }
        }
        break;
      case 'buatJurnal':
        title = "Isi Jurnal Harian";
        subtitle = "Catat kegiatan magangmu hari ini";
        themeColor = const Color(0xFFFF9800); // Orange
        icon = Icons.edit_note_rounded;
        btnText = "Isi Jurnal";
        onAction = widget.onIsiJurnal;
        isActive = true;

        // Tampilkan info waktu absen pulang
        if (_countdownDuration.inSeconds > 0) {
          countdownText =
              "Absen pulang dibuka dalam: ${_formatDuration(_countdownDuration)}";
          showCountdown = true;
        }
        break;
      case 'absenPulang':
        title = "Waktunya Pulang";
        subtitle = "Selesaikan hari ini dengan absen pulang";
        themeColor = const Color(0xFFE53935); // Merah
        icon = Icons.logout_rounded;

        if (_canAbsenPulang) {
          btnText = "Absen Keluar";
          onAction = widget.onAbsenPulang;
          isActive = true;
          final jamPulangStr = widget.penempatanData?.mitra?.jamPulang;
          if (jamPulangStr != null) {
            countdownText = "✅ Waktu absen pulang sudah dibuka";
            showCountdown = true;
          }
        } else {
          btnText = "Belum Waktunya";
          isActive = false;
          if (_countdownDuration.inSeconds > 0) {
            countdownText =
                "Absen pulang dibuka dalam: ${_formatDuration(_countdownDuration)}";
            showCountdown = true;
          }
        }
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
            color: Colors.black.withValues(alpha: 0.06),
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
                    color: themeColor.withValues(alpha: 0.1),
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

          // Countdown Section
          if (showCountdown && countdownText != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _countdownDuration.inSeconds > 0
                      ? const Color(
                          0xFFFFF8E1) // Kuning muda untuk countdown aktif
                      : _canAbsenPulang || widget.statusAbsensi == 'absenMasuk'
                          ? (_countdownDuration.inSeconds == 0 &&
                                  widget.statusAbsensi == 'absenMasuk'
                              ? const Color(
                                  0xFFFFEBEE) // Merah muda untuk terlambat
                              : const Color(
                                  0xFFE8F5E9)) // Hijau muda untuk siap
                          : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _countdownDuration.inSeconds > 0
                        ? Colors.orange.withValues(alpha: 0.3)
                        : _canAbsenPulang ||
                                widget.statusAbsensi == 'absenMasuk'
                            ? (_countdownDuration.inSeconds == 0 &&
                                    widget.statusAbsensi == 'absenMasuk'
                                ? Colors.red.withValues(alpha: 0.3)
                                : Colors.green.withValues(alpha: 0.3))
                            : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _countdownDuration.inSeconds > 0
                          ? Icons.timer_outlined
                          : (_countdownDuration.inSeconds == 0 &&
                                  widget.statusAbsensi == 'absenMasuk' &&
                                  !_canAbsenPulang
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline),
                      size: 18,
                      color: _countdownDuration.inSeconds > 0
                          ? Colors.orange[700]
                          : (_countdownDuration.inSeconds == 0 &&
                                  widget.statusAbsensi == 'absenMasuk'
                              ? Colors.red[700]
                              : Colors.green[700]),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        countdownText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _countdownDuration.inSeconds > 0
                              ? Colors.orange[800]
                              : (_countdownDuration.inSeconds == 0 &&
                                      widget.statusAbsensi == 'absenMasuk'
                                  ? Colors.red[800]
                                  : Colors.green[800]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

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

// =============================================================================
// NO PLACEMENT CARD - Card untuk siswa yang belum memilih tempat PKL
// =============================================================================
class NoPlacementCard extends StatelessWidget {
  final VoidCallback onPilihTempat;

  const NoPlacementCard({
    super.key,
    required this.onPilihTempat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.search_rounded, size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          const Text(
            "Kamu belum memiliki tempat PKL",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Segera cari dan ajukan diri ke perusahaan favoritmu sekarang!",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPilihTempat,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A60AA),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Pilih Tempat PKL",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PENDING CARD - Card untuk siswa yang menunggu tanggal masuk PKL
// =============================================================================
class PendingCard extends StatefulWidget {
  final PenempatanData? penempatanData;

  const PendingCard({
    super.key,
    required this.penempatanData,
  });

  @override
  State<PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends State<PendingCard> {
  Timer? _countdownTimer;
  Duration _countdownDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  @override
  void didUpdateWidget(PendingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.penempatanData?.tglMulai != widget.penempatanData?.tglMulai) {
      _initializeCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initializeCountdown() {
    _countdownTimer?.cancel();

    final tglMulaiStr = widget.penempatanData?.tglMulai;
    if (tglMulaiStr == null || tglMulaiStr.isEmpty) return;

    try {
      final tglMulai = DateTime.parse(tglMulaiStr);
      final now = DateTime.now();

      // Set waktu target ke 00:00:00 hari tersebut
      final targetDate = DateTime(tglMulai.year, tglMulai.month, tglMulai.day);
      final todayMidnight = DateTime(now.year, now.month, now.day);

      if (todayMidnight.isBefore(targetDate)) {
        _countdownDuration = targetDate.difference(now);
        _startCountdown();
      } else {
        _countdownDuration = Duration.zero;
      }
    } catch (e) {
      _countdownDuration = Duration.zero;
    }

    if (mounted) setState(() {});
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownDuration.inSeconds > 0) {
        setState(() {
          _countdownDuration = _countdownDuration - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatCountdown() {
    final days = _countdownDuration.inDays;
    final hours = _countdownDuration.inHours.remainder(24);
    final minutes = _countdownDuration.inMinutes.remainder(60);
    final seconds = _countdownDuration.inSeconds.remainder(60);

    if (days > 0) {
      return '$days Hari ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Belum ditentukan';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: Color(0xFF4A60AA)),
              SizedBox(width: 8),
              Text(
                "Menunggu Tanggal Masuk",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A60AA),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          const Text("Tanggal Masuk PKL", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            _formatDate(widget.penempatanData?.tglMulai),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Countdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  "Waktu Tersisa",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _countdownDuration.inSeconds > 0
                      ? _formatCountdown()
                      : "Sudah waktunya!",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FINISHED CARD - Card untuk siswa yang PKL-nya sudah selesai
// =============================================================================
class FinishedCard extends StatelessWidget {
  final PenempatanData? penempatanData;

  const FinishedCard({
    super.key,
    required this.penempatanData,
  });

  @override
  Widget build(BuildContext context) {
    final nilai = penempatanData?.nilai;
    final komentar = penempatanData?.komentarSupervisor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "PKL Selesai",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 24),

          // Nilai Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4A60AA).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Nilai Akhir",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  nilai != null ? nilai.toString() : "Belum Dinilai",
                  style: TextStyle(
                    fontSize: nilai != null ? 48 : 24,
                    fontWeight: FontWeight.bold,
                    color: nilai != null
                        ? (nilai >= 70
                            ? const Color(0xFF4A60AA)
                            : Colors.orange)
                        : Colors.grey,
                  ),
                ),
                if (nilai != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getGradeColor(nilai).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getGradeLabel(nilai),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getGradeColor(nilai),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Komentar Section (jika ada)
          if (komentar != null && komentar.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.comment_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        "Komentar Supervisor",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    komentar,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getGradeColor(int nilai) {
    if (nilai >= 85) return Colors.green;
    if (nilai >= 70) return const Color(0xFF4A60AA);
    if (nilai >= 55) return Colors.orange;
    return Colors.red;
  }

  String _getGradeLabel(int nilai) {
    if (nilai >= 85) return "Sangat Baik";
    if (nilai >= 70) return "Baik";
    if (nilai >= 55) return "Cukup";
    return "Perlu Perbaikan";
  }
}

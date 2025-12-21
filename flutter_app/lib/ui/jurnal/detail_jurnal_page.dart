import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/jurnal_model.dart';
import 'package:flutter_app/core/constants/api_constans.dart';

class DetailJurnalPage extends StatelessWidget {
  final Jurnal jurnal;

  const DetailJurnalPage({super.key, required this.jurnal});

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      const days = [
        'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
      ];
      String day = days[date.weekday - 1];
      String month = months[date.month - 1];
      return '$day, ${date.day} $month ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Jurnal',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A60AA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF4A60AA),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(jurnal.tanggal),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF101828),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tanggal Jurnal',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(jurnal.status),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Judul Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.title, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Judul Kegiatan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    jurnal.judul,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Deskripsi Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Deskripsi Kegiatan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    jurnal.deskripsi,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF344054),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // Foto Section (jika ada)
            if (jurnal.fotoKegiatan != null && jurnal.fotoKegiatan!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.photo_camera, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Foto Kegiatan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        '${ApiConstants.baseUrl.replaceAll('/api', '')}/storage/${jurnal.fotoKegiatan}',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Komentar Section (jika ada)
            if (jurnal.komentar != null && jurnal.komentar!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: jurnal.status == 'revisi' || jurnal.status == 'ditolak'
                      ? const Color(0xFFFEF3F2)
                      : const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: jurnal.status == 'revisi' || jurnal.status == 'ditolak'
                        ? const Color(0xFFFECDCA)
                        : const Color(0xFFABEFC6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.comment,
                          color: jurnal.status == 'revisi' || jurnal.status == 'ditolak'
                              ? const Color(0xFFB42318)
                              : const Color(0xFF027A48),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Komentar Pembimbing',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: jurnal.status == 'revisi' || jurnal.status == 'ditolak'
                                ? const Color(0xFFB42318)
                                : const Color(0xFF027A48),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      jurnal.komentar!,
                      style: TextStyle(
                        fontSize: 14,
                        color: jurnal.status == 'revisi' || jurnal.status == 'ditolak'
                            ? const Color(0xFFB42318)
                            : const Color(0xFF027A48),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status.toLowerCase()) {
      case 'disetujui':
        bgColor = const Color(0xFFECFDF3);
        textColor = const Color(0xFF027A48);
        icon = Icons.check_circle;
        text = 'Disetujui';
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF0C7);
        textColor = const Color(0xFFB54708);
        icon = Icons.access_time_filled;
        text = 'Pending';
        break;
      case 'ditolak':
      case 'revisi':
        bgColor = const Color(0xFFFEF3F2);
        textColor = const Color(0xFFB42318);
        icon = Icons.cancel;
        text = 'Revisi';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.help;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

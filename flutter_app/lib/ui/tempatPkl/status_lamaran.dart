import 'package:flutter/material.dart';
import 'package:flutter_app/core/api/client/pengajuan_client.dart';
import 'package:flutter_app/core/api/dio_client.dart';

class StatusLamaran extends StatefulWidget {
  const StatusLamaran({super.key});

  @override
  State<StatusLamaran> createState() => _StatusLamaranState();
}

class _StatusLamaranState extends State<StatusLamaran> {
  late PengajuanClient _client;
  bool _isLoading = true;
  Map<String, dynamic>? _pengajuan; // Using dynamic map from client for now
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _client = PengajuanClient(DioClient().dio);
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final response = await _client.getStatus();
      if (response.success) {
        setState(() {
          _pengajuan = response.data != null
              ? Map<String, dynamic>.from(response.data)
              : null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Gagal memuat status.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Terjadi kesalahan koneksi.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Status Lamaran")),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_pengajuan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Status Lamaran")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text("Belum ada lamaran aktif."),
            ],
          ),
        ),
      );
    }

    // Extract Data
    final status = _pengajuan!['status'] ?? 'pending';
    final mitra = _pengajuan!['mitra_industri'];
    final namaMitra = mitra != null ? mitra['nama_instansi'] : 'Mitra Industri';
    final bidang = mitra != null ? mitra['bidang_usaha'] : '-';
    final tglAjuan = _pengajuan!['tgl_ajuan'] ?? '-';

    Color statusColor = Colors.orange;
    String statusText = "Menunggu Konfirmasi";

    if (status == 'diterima') {
      statusColor = Colors.green;
      statusText = "Diterima";
    } else if (status == 'ditolak') {
      statusColor = Colors.red;
      statusText = "Ditolak";
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Status Lamaran", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.blue[50], shape: BoxShape.circle),
                    child: const Icon(Icons.business,
                        size: 40, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 16),
                  Text(namaMitra,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(bidang, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 24),
                  _buildRow("Tanggal Pengajuan", tglAjuan),
                  const SizedBox(height: 12),
                  _buildRow("Durasi", "${_pengajuan!['durasi']} Bulan"),
                  const SizedBox(height: 12),
                  _buildRow("Status", statusText,
                      valueColor: statusColor, isBold: true),
                ],
              ),
            ),

            if (status == 'diterima') ...[
              const SizedBox(height: 24),
              const Text("Selamat! Lamaran Anda diterima.",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
              const Text("Silahkan tunggu info penempatan.",
                  style: TextStyle(color: Colors.grey)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

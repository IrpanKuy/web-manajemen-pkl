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
  List<dynamic> _history = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _client = PengajuanClient(DioClient().dio);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await _client.getHistory();
      if (response.success) {
        setState(() {
          _history = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Gagal memuat riwayat lamaran.";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
      setState(() {
        _errorMessage = "Terjadi kesalahan koneksi atau data kosong.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background abu-abu muda
      appBar: AppBar(
        title: const Text(
          "Lamaran", // Sesuai judul di gambar
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF2C48A5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _loadHistory,
                          child: const Text("Coba Lagi"))
                    ],
                  ),
                )
              : _history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open,
                              size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text("Belum ada riwayat lamaran.",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return _buildCleanCard(item);
                      },
                    ),
    );
  }

  Widget _buildCleanCard(Map<String, dynamic> item) {
    // Extract Data
    final mitra = item['mitra'] ?? {};
    final namaMitra = mitra['nama_instansi'] ?? 'Nama Instansi Tidak Tersedia';
    final bidangUsaha =
        mitra['bidang_usaha'] ?? '-'; // Digunakan sebagai subtitle

    final status = item['status'] ?? 'pending';
    final tglAjuan = item['tgl_ajuan'] ?? '-';

    // Data tambahan yang dipertahankan
    final durasi = item['durasi'] ?? 0;
    final jamKerja =
        "${mitra['jam_masuk']?.toString().substring(0, 5) ?? '--'} - ${mitra['jam_pulang']?.toString().substring(0, 5) ?? '--'}";
    final alasanPenolakan = item['alasan_penolakan'];

    // Status Config (Meniru gaya visual gambar)
    Color statusTextColor;
    Color statusBgColor;
    String statusText;

    switch (status) {
      case 'diterima':
        statusTextColor = const Color(0xFF2E7D32); // Hijau Tua
        statusBgColor = const Color(0xFFC8E6C9); // Hijau Muda Pastel
        statusText = "Diterima";
        break;
      case 'ditolak':
        statusTextColor = const Color(0xFFC62828); // Merah Tua
        statusBgColor = const Color(0xFFFFCDD2); // Merah Muda Pastel
        statusText = "Ditolak";
        break;
      default: // pending
        statusTextColor = const Color(0xFF1565C0); // Biru Tua
        statusBgColor = const Color(0xFFBBDEFB); // Biru Muda Pastel
        statusText = "Diajukan";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER ROW: Nama Mitra & Badge Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaMitra,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bidangUsaha, // Subtitle seperti "Frontend Developer" di gambar
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // 2. EXTRA INFO (Isi kode lama yang dipertahankan tapi dirapikan)
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                _buildSimpleInfo(Icons.calendar_month, "$durasi Bulan"),
                const SizedBox(width: 16),
                Container(width: 1, height: 24, color: Colors.grey[300]),
                const SizedBox(width: 16),
                _buildSimpleInfo(Icons.access_time, jamKerja),
              ],
            ),
          ),

          // Jika Ditolak, tampilkan alasan
          if (status == 'ditolak' && alasanPenolakan != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Alasan Penolakan:",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC62828))),
                  const SizedBox(height: 4),
                  Text(alasanPenolakan,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFD32F2F))),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // 3. DIVIDER
          Divider(color: Colors.grey[200], thickness: 1),

          const SizedBox(height: 12),

          // 4. FOOTER: Tanggal Pengajuan
          Text(
            "Tanggal Pengajuan: $tglAjuan",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

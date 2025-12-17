import 'package:flutter/material.dart';
import 'package:flutter_app/core/api/client/placement_client.dart';
import 'package:flutter_app/core/api/dio_client.dart';
import 'package:flutter_app/data/models/mitra_model.dart';

class DetailMitra extends StatefulWidget {
  const DetailMitra({super.key});

  @override
  State<DetailMitra> createState() => _DetailMitraState();
}

class _DetailMitraState extends State<DetailMitra> {
  late PlacementClient _client;
  bool _isLoading = true;
  dynamic _placementData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _client = PlacementClient(DioClient().dio);
    _loadPlacement();
  }

  Future<void> _loadPlacement() async {
    try {
      final response = await _client.getPlacementDetail();
      if (response.success && response.data != null) {
        setState(() {
          _placementData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? "Belum ada penetapan lokasi PKL.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text("Detail Mitra", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
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
                      Icon(Icons.business_center_outlined,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.grey)),
                      if (_errorMessage!.contains("Gagal"))
                        TextButton(
                            onPressed: _loadPlacement,
                            child: const Text("Coba Lagi"))
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    // Extract Data safely
    final mitra = _placementData['mitra'];
    if (mitra == null) return const Center(child: Text("Data mitra corrupt"));

    // We can try to cast to MitraModel if structure matches, or just map manually
    // Since PlacementController uses `with(['mitra'])` it returns array structure.

    final String namaInstansi = mitra['nama_instansi'] ?? "Nama Instansi";
    final String bidangUsaha = mitra['bidang_usaha'] ?? "Bidang Usaha";
    final alamatData = mitra['alamat'];

    // Format Alamat
    String alamat = "Alamat tidak tersedia";
    if (alamatData != null) {
      List<String> parts = [];
      if (alamatData['detail_alamat'] != null)
        parts.add(alamatData['detail_alamat']);
      if (alamatData['kecamatan'] != null)
        parts.add("Kec. " + alamatData['kecamatan']);
      if (alamatData['kabupaten'] != null) parts.add(alamatData['kabupaten']);
      if (parts.isNotEmpty) alamat = parts.join(", ");
    }

    final String desc = mitra['deskripsi'] ?? "-";
    final String jamMasuk = mitra['jam_masuk'] != null
        ? mitra['jam_masuk'].substring(0, 5)
        : "--:--";
    final String jamPulang = mitra['jam_pulang'] != null
        ? mitra['jam_pulang'].substring(0, 5)
        : "--:--";

    // Placement Specifics
    final String tglMulai = _placementData['tgl_mulai'] ?? "-";
    final String tglSelesai = _placementData['tgl_selesai'] ?? "-";
    final pembimbing = _placementData['pembimbing'];
    final String namaPembimbing = pembimbing != null
        ? pembimbing['username']
        : "Belum ditentukan"; // User model has username, or name if profile attached

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image Placeholder
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage(
                      "assets/images/placeholder_company.png"), // Ensure asset exists or fallback
                  fit: BoxFit.cover,
                )),
            child: const Center(
                child: Icon(Icons.business, size: 60, color: Colors.grey)),
          ),
          const SizedBox(height: 24),

          // Title
          Text(namaInstansi,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(bidangUsaha,
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.w600)),

          const SizedBox(height: 24),

          // Info Rows
          _buildIconRow(Icons.location_on, alamat),
          const SizedBox(height: 16),
          _buildIconRow(Icons.access_time, "Jam Kerja: $jamMasuk - $jamPulang"),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Placement Details
          const Text("Detail Penempatan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _buildInfoCard("Tanggal Mulai", tglMulai, Icons.calendar_today),
          const SizedBox(height: 12),
          _buildInfoCard("Tanggal Selesai", tglSelesai, Icons.event),
          const SizedBox(height: 12),
          _buildInfoCard("Pembimbing Lapangan", namaPembimbing, Icons.person),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Description
          const Text("Tentang Perusahaan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(desc,
              style: const TextStyle(height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.black87, fontSize: 14))),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

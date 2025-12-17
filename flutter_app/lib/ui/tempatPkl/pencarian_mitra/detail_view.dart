import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_app/ui/lamaran.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/core/api/client/pengajuan_client.dart';
import 'package:flutter_app/data/models/response/mitra_response.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MitraDetailView extends StatefulWidget {
  final ScrollController scrollController;
  final MitraModel mitra;
  final Position? currentPosition;
  final VoidCallback onClose;
  final PengajuanClient pengajuanClient;

  const MitraDetailView({
    super.key,
    required this.scrollController,
    required this.mitra,
    this.currentPosition,
    required this.onClose,
    required this.pengajuanClient,
  });

  @override
  State<MitraDetailView> createState() => _MitraDetailViewState();
}

class _MitraDetailViewState extends State<MitraDetailView> {
  bool _isSubmitting = false;
  File? _cvFile;
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  // --- FORM LOGIC ---
  Future<void> _pickCV() async {
    // 1. CEK APAKAH DI WEB
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Fitur upload file belum tersedia di Web. Mohon gunakan Aplikasi Android/Desktop."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _cvFile = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error saat pick file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal membuka galeri: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submitPengajuan() async {
    // Validasi input
    if (_durationCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Mohon lengkapi semua data (Durasi, Deskripsi).")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.pengajuanClient.postPengajuan(
          mitraId: widget.mitra.id,
          durasi: int.tryParse(_durationCtrl.text) ?? 3,
          deskripsi: _descCtrl.text,
          cv: _cvFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Lamaran berhasil dikirim!"),
            backgroundColor: Colors.green));

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const StatusLamaran()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Gagal mengirim lamaran: ${e.toString()}"),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance(widget.mitra.alamat?.location);

    return Column(
      children: [
        // Handle Bar
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mitra.namaInstansi,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                "${widget.mitra.bidangUsaha ?? 'Bidang Usaha'}",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: widget.onClose)
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          size: 20, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatAddress(widget.mitra.alamat),
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text("$distance dari lokasi anda",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                          child: _buildDetailInfoCard(
                              "KUOTA",
                              "${widget.mitra.kuota ?? '-'} Orang",
                              Icons.people_outline)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildDetailInfoCard(
                              "JAM KERJA",
                              "${widget.mitra.jamMasuk?.substring(0, 5) ?? '--'} - ${widget.mitra.jamPulang?.substring(0, 5) ?? '--'}",
                              Icons.access_time)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Deskripsi
                  const Text("Tentang Program",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      widget.mitra.deskripsi ?? "Tidak ada deskripsi tersedia.",
                      style:
                          const TextStyle(color: Colors.black87, height: 1.5)),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // --- FORM PENGAJUAN ---
                  const Text("Form Lamaran",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // 1. Durasi
                  const Text("Durasi Magang (Bulan)",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Contoh: 3",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Upload CV
                  const Text("Upload CV (Opsional)",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _pickCV,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.upload_file,
                                color: Color(0xFF1E3A8A)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(
                              _cvFile != null
                                  ? _cvFile!.path.split('/').last
                                  : "Pilih File CV (Opsional)...",
                              style: TextStyle(
                                  color: _cvFile != null
                                      ? Colors.black
                                      : Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            )),
                            if (_cvFile != null)
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 16)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Deskripsi
                  const Text("Deskripsi / Motivasi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Jelaskan mengapa anda ingin magang di sini...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : (widget.mitra.kuota != null &&
                                  widget.mitra.kuota! > 0)
                              ? _submitPengajuan
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Lamar Sekarang",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets & Methods ---
  Widget _buildDetailInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  String _formatAddress(dynamic alamat) {
    if (alamat == null) return "Alamat tidak tersedia";
    String detail = alamat.detailAlamat ?? "";
    List<String> parts = [];
    if (detail.isNotEmpty) parts.add(detail);
    try {
      if (alamat.kecamatan != null) parts.add("Kec. ${alamat.kecamatan}");
      if (alamat.kabupaten != null) parts.add(alamat.kabupaten);
      if (alamat.profinsi != null) parts.add(alamat.profinsi);
    } catch (e) {}
    if (parts.isEmpty) return "Lokasi belum diatur";
    return parts.join(", ");
  }

  String _calculateDistance(String? targetLoc) {
    if (widget.currentPosition == null || targetLoc == null) return "-";
    LatLng? target = _parseLocation(targetLoc);
    if (target == null) return "-";
    double distInMeters = Geolocator.distanceBetween(
        widget.currentPosition!.latitude,
        widget.currentPosition!.longitude,
        target.latitude,
        target.longitude);
    if (distInMeters > 1000) {
      return "${(distInMeters / 1000).toStringAsFixed(1)} km";
    }
    return "${distInMeters.toStringAsFixed(0)} m";
  }

  LatLng? _parseLocation(String? locationStr) {
    if (locationStr == null || locationStr.isEmpty) return null;
    try {
      if (locationStr.length > 20 &&
          RegExp(r'^[0-9A-Fa-f]+$').hasMatch(locationStr)) {
        return _parseWKBPoint(locationStr);
      }
      if (locationStr.startsWith("POINT")) {
        final content = locationStr.substring(6, locationStr.length - 1);
        final parts = content.split(' ');
        if (parts.length >= 2)
          return LatLng(double.parse(parts[1]), double.parse(parts[0]));
      }
      if (locationStr.contains(',')) {
        final parts = locationStr.split(',');
        if (parts.length == 2)
          return LatLng(double.parse(parts[0]), double.parse(parts[1]));
      }
    } catch (e) {}
    return null;
  }

  LatLng? _parseWKBPoint(String hex) {
    try {
      List<int> bytes = [];
      for (int i = 0; i < hex.length; i += 2)
        bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
      final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
      bool isLittleEndian = byteData.getUint8(0) == 1;
      double x =
          byteData.getFloat64(9, isLittleEndian ? Endian.little : Endian.big);
      double y =
          byteData.getFloat64(17, isLittleEndian ? Endian.little : Endian.big);
      return LatLng(y, x);
    } catch (e) {
      return null;
    }
  }
}

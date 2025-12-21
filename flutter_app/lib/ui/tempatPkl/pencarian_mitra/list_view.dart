import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/response/mitra_response.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MitraListView extends StatelessWidget {
  final ScrollController scrollController;
  final List<MitraModel> mitras;
  final bool isLoading;
  final Position? currentPosition;
  final Function(String) onSearchChanged;
  final Function(MitraModel) onMitraSelected;

  const MitraListView({
    super.key,
    required this.scrollController,
    required this.mitras,
    required this.isLoading,
    this.currentPosition,
    required this.onSearchChanged,
    required this.onMitraSelected,
  });

  @override
  Widget build(BuildContext context) {
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

        // Search Bar (Padding dikurangi sedikit 8->4 vertical)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: "Cari lokasi atau perusahaan...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: const Icon(Icons.tune, color: Color(0xFF1E3A8A)),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // List Content
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : mitras.isEmpty
                  ? SingleChildScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("Tidak ada mitra ditemukan",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse
                        },
                      ),
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        itemCount: mitras.length,
                        itemBuilder: (context, index) {
                          final mitra = mitras[index];
                          final distance =
                              _calculateDistance(mitra.alamat?.location);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.business,
                                          color: Color(0xFF1E3A8A)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(mitra.namaInstansi,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          const SizedBox(height: 4),
                                          Text(
                                              "${mitra.bidangUsaha ?? 'Umum'} • Vocational",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _formatAddress(mitra.alamat),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(distance,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                          "Kuota: ${mitra.kuota}/${mitra.kuota}",
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => onMitraSelected(mitra),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF1E3A8A),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 0),
                                        minimumSize: const Size(0, 36),
                                      ),
                                      child: const Text("Lihat",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // --- Helpers ---
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
    if (currentPosition == null || targetLoc == null) return "-";
    LatLng? target = _parseLocation(targetLoc);
    if (target == null) return "-";
    double distInMeters = Geolocator.distanceBetween(currentPosition!.latitude,
        currentPosition!.longitude, target.latitude, target.longitude);
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
    } catch (e) {
      return null;
    }
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

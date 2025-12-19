import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/response/mitra_response.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MitraMapView extends StatelessWidget {
  final MapController mapController;
  final List<MitraModel> mitras;
  final MitraModel? selectedMitra;
  final Position? currentPosition;
  final Function(MitraModel) onMitraSelected;

  const MitraMapView({
    super.key,
    required this.mapController,
    required this.mitras,
    required this.selectedMitra,
    this.currentPosition,
    required this.onMitraSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: const MapOptions(
        initialCenter: LatLng(-7.2575, 112.7521), // Default Surabaya
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.flutter_app',
        ),
        MarkerLayer(
          markers: mitras
              .map((mitra) {
                LatLng? loc = _parseLocation(mitra.alamat?.location);
                if (loc == null) return null;

                bool isSelected = selectedMitra?.id == mitra.id;

                return Marker(
                  point: loc,
                  width: isSelected ? 60 : 45,
                  height: isSelected ? 60 : 45,
                  child: GestureDetector(
                    onTap: () => onMitraSelected(mitra),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${mitra.kuota} Spots",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        Icon(
                          Icons.location_on,
                          color:
                              isSelected ? const Color(0xFF1E3A8A) : Colors.red,
                          size: isSelected ? 40 : 35,
                        ),
                      ],
                    ),
                  ),
                );
              })
              .whereType<Marker>()
              .toList(),
        ),
        if (currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                    currentPosition!.latitude, currentPosition!.longitude),
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.3),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: const Icon(Icons.my_location,
                      color: Colors.blue, size: 20),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Helper Parsing Location (Private di file ini)
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
        if (parts.length >= 2) {
          return LatLng(double.parse(parts[1]), double.parse(parts[0]));
        }
      }
      if (locationStr.contains(',')) {
        final parts = locationStr.split(',');
        if (parts.length == 2) {
          return LatLng(double.parse(parts[0]), double.parse(parts[1]));
        }
      }
    } catch (e) {
      debugPrint("Error parsing location: $e");
    }
    return null;
  }

  LatLng? _parseWKBPoint(String hex) {
    try {
      List<int> bytes = [];
      for (int i = 0; i < hex.length; i += 2) {
        bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
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

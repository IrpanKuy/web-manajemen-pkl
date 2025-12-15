import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/api/client/mitra_client.dart';
import 'package:flutter_app/core/api/client/pengajuan_client.dart';
import 'package:flutter_app/core/api/dio_client.dart';
import 'package:flutter_app/data/models/mitra_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// Imports komponen yang baru dipisah
import 'map_view.dart';
import 'list_view.dart';
import 'detail_view.dart';

class PencarianMitraPage extends StatefulWidget {
  const PencarianMitraPage({super.key});

  @override
  State<PencarianMitraPage> createState() => _PencarianMitraPageState();
}

class _PencarianMitraPageState extends State<PencarianMitraPage> {
  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  late MitraClient _mitraClient;
  late PengajuanClient _pengajuanClient;

  List<MitraModel> _allMitras = [];
  List<MitraModel> _filteredMitras = [];

  bool _isLoading = true;
  Position? _currentPosition;
  String _searchQuery = "";

  MitraModel? _selectedMitra;

  @override
  void initState() {
    super.initState();
    final dio = DioClient().dio;
    _mitraClient = MitraClient(dio);
    _pengajuanClient = PengajuanClient(dio);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getCurrentLocation();
    await _fetchMitras();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      _mapController.move(LatLng(position.latitude, position.longitude), 13.0);
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _fetchMitras() async {
    try {
      final response = await _mitraClient.getMitras();
      if (response.success && response.data != null) {
        setState(() {
          _allMitras = response.data!;
          _filteredMitras = _allMitras;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching mitras: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMitras = _allMitras;
      } else {
        _filteredMitras = _allMitras.where((mitra) {
          final name = mitra.namaInstansi.toLowerCase();
          final category = (mitra.bidangUsaha ?? "").toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q) || category.contains(q);
        }).toList();
      }
    });
  }

  void _onMitraSelected(MitraModel mitra) {
    setState(() {
      _selectedMitra = mitra;
    });

    LatLng? location = _parseLocation(mitra.alamat?.location);
    if (location != null) {
      _mapController.move(location, 15.0);
    }

    if (_sheetController.isAttached) {
      _sheetController.animateTo(0.5,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _closeDetail() {
    setState(() {
      _selectedMitra = null;
    });
  }

  // Helper Parsing Location (Hanya digunakan untuk move map di sini)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. MAP VIEW
          MitraMapView(
            mapController: _mapController,
            mitras: _filteredMitras,
            selectedMitra: _selectedMitra,
            currentPosition: _currentPosition,
            onMitraSelected: _onMitraSelected,
          ),

          // 2. BACK BUTTON
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (_selectedMitra != null) {
                    _closeDetail();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),

          // 3. DRAGGABLE SHEET
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.45,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedMitra == null
                      ? MitraListView(
                          scrollController: scrollController,
                          mitras: _filteredMitras,
                          isLoading: _isLoading,
                          currentPosition: _currentPosition,
                          onSearchChanged: _onSearchChanged,
                          onMitraSelected: _onMitraSelected,
                        )
                      : MitraDetailView(
                          scrollController: scrollController,
                          mitra: _selectedMitra!,
                          currentPosition: _currentPosition,
                          onClose: _closeDetail,
                          pengajuanClient: _pengajuanClient,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

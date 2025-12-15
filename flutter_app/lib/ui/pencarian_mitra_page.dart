// import 'package:flutter/material.dart';
// import 'package:flutter_app/core/api/client/mitra_client.dart';
// import 'package:flutter_app/core/api/dio_client.dart';
// import 'package:flutter_app/data/models/mitra_model.dart';
// import 'package:flutter_app/ui/detail_mitra_page.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';

// class PencarianMitraPage extends StatefulWidget {
//   const PencarianMitraPage({super.key});

//   @override
//   State<PencarianMitraPage> createState() => _PencarianMitraPageState();
// }

// class _PencarianMitraPageState extends State<PencarianMitraPage> {
//   final MapController _mapController = MapController();
//   late MitraClient _mitraClient;

//   List<MitraModel> _allMitras = [];
//   List<MitraModel> _filteredMitras = [];

//   bool _isLoading = true;
//   Position? _currentPosition;
//   String _searchQuery = "";

//   @override
//   void initState() {
//     super.initState();
//     _mitraClient = MitraClient(DioClient().dio);
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     await _getCurrentLocation();
//     await _fetchMitras();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) return;

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) return;
//       }

//       if (permission == LocationPermission.deniedForever) return;

//       Position position = await Geolocator.getCurrentPosition();
//       setState(() {
//         _currentPosition = position;
//       });

//       // Move map to user location initially
//       _mapController.move(
//         LatLng(position.latitude, position.longitude),
//         13.0
//       );
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//   }

//   Future<void> _fetchMitras() async {
//     try {
//       // Fetch ALL mitras that match the user's major (Backend handles filtering by Jurusan)
//       final response = await _mitraClient.getMitras();
//       if (response.success && response.data != null) {
//         setState(() {
//           _allMitras = response.data!;
//           _filteredMitras = _allMitras; // Initial state: Show all valid mitras
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching mitras: $e");
//       setState(() => _isLoading = false);
//     }
//   }

//   void _onSearchChanged(String query) {
//     setState(() {
//       _searchQuery = query;
//       if (query.isEmpty) {
//         _filteredMitras = _allMitras;
//       } else {
//         _filteredMitras = _allMitras.where((mitra) {
//           final name = mitra.namaInstansi.toLowerCase();
//           final category = (mitra.bidangUsaha ?? "").toLowerCase();
//           final q = query.toLowerCase();
//           return name.contains(q) || category.contains(q);
//         }).toList();
//       }
//     });
//   }

//   void _onMitraSelected(MitraModel mitra) {
//     // 1. Get Location
//     LatLng? location = _parseLocation(mitra.alamat?.location);
//     if (location != null) {
//       // 2. Animate Map
//       _mapController.move(location, 15.0);
//     }
//   }

//   LatLng? _parseLocation(String? locationStr) {
//     if (locationStr == null || locationStr.isEmpty) return null;

//     try {
//       // 1. Try "POINT(lng lat)" (WKT format often returned by PostGIS AsText)
//       // Note: WKT is usually POINT(x y) i.e. POINT(lng lat)
//       if (locationStr.startsWith("POINT")) {
//         final content = locationStr.substring(6, locationStr.length - 1); // remove POINT( and )
//         final parts = content.split(' ');
//         if (parts.length >= 2) {
//           return LatLng(double.parse(parts[1]), double.parse(parts[0])); // Lat, Lng
//         }
//       }

//       // 2. Try "lat,lng"
//       if (locationStr.contains(',')) {
//         final parts = locationStr.split(',');
//         if (parts.length == 2) {
//           return LatLng(double.parse(parts[0]), double.parse(parts[1]));
//         }
//       }
//     } catch (e) {
//       print("Error parsing location: $locationStr - $e");
//       return null;
//     }
//     return null;
//   }

//   // Helper Distance
//   String _calculateDistance(String? targetLoc) {
//     if (_currentPosition == null || targetLoc == null) return "-";
//     LatLng? target = _parseLocation(targetLoc);
//     if (target == null) return "-";

//     double distInMeters = Geolocator.distanceBetween(
//       _currentPosition!.latitude,
//       _currentPosition!.longitude,
//       target.latitude,
//       target.longitude
//     );

//     if (distInMeters > 1000) {
//       return "${(distInMeters / 1000).toStringAsFixed(1)} km";
//     }
//     return "${distInMeters.toStringAsFixed(0)} m";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 1. MAP BACKGROUND
//           FlutterMap(
//             mapController: _mapController,
//             options: const MapOptions(
//               initialCenter: LatLng(-6.200000, 106.816666), // Jakarta Default
//               initialZoom: 12.0,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 userAgentPackageName: 'com.example.app',
//               ),
//               MarkerLayer(
//                 markers: _allMitras.map((mitra) {
//                   // Show ALL markers on map, regardless of List Filter
//                   LatLng? loc = _parseLocation(mitra.alamat?.location);
//                   if (loc == null) return null;

//                   return Marker(
//                     point: loc,
//                     width: 40,
//                     height: 40,
//                     child: const Icon(Icons.location_on, color: Colors.red, size: 40),
//                   );
//                 }).whereType<Marker>().toList(), // Filter out nulls
//               ),
//               // User Marker
//               if (_currentPosition != null)
//                 MarkerLayer(
//                   markers: [
//                     Marker(
//                       point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//                       width: 40,
//                       height: 40,
//                       child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
//                     ),
//                   ],
//                 ),
//             ],
//           ),

//           // 2. SEARCH BAR (Floating Top)
//           Positioned(
//             top: 50,
//             left: 16,
//             right: 16,
//             child: Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               child: TextField(
//                 onChanged: _onSearchChanged,
//                 decoration: InputDecoration(
//                   hintText: "Cari lokasi atau perusahaan...",
//                   prefixIcon: const Icon(Icons.search),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.filter_list),
//                     onPressed: () {
//                       // Optional: Advanced Filter Dialog
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // 3. HORIZONTAL LIST (Floating Bottom)
//           Positioned(
//             bottom: 30,
//             left: 0,
//             right: 0,
//             height: 180, // Height for the cards
//             child: _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: _filteredMitras.length,
//                   itemBuilder: (context, index) {
//                     final mitra = _filteredMitras[index];
//                     return _buildMitraCard(mitra);
//                   },
//                 ),
//           ),

//            // Back Button
//           Positioned(
//             top: 50,
//             left: 16,
//             child: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.black),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMitraCard(MitraModel mitra) {
//     String distance = _calculateDistance(mitra.alamat?.location);

//     return GestureDetector(
//       onTap: () {
//          _onMitraSelected(mitra);
//       },
//       child: Container(
//         width: 300,
//         margin: const EdgeInsets.only(right: 16),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 // Icon Placeholder
//                 Container(
//                   width: 40, height: 40,
//                   decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
//                   child: const Icon(Icons.business, color: Color(0xFF4A60AA)),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(mitra.namaInstansi,
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                         maxLines: 1, overflow: TextOverflow.ellipsis),
//                       Text("${mitra.bidangUsaha ?? '-'} • ${mitra.alamat?.kabupaten ?? '-'}",
//                         style: const TextStyle(color: Colors.grey, fontSize: 12),
//                         maxLines: 1, overflow: TextOverflow.ellipsis),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 const Icon(Icons.location_on, size: 14, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: Text(mitra.alamat?.detailAlamat ?? "Alamat tidak tersedia",
//                     style: const TextStyle(color: Colors.black87, fontSize: 12),
//                     maxLines: 1, overflow: TextOverflow.ellipsis),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text("$distance dari lokasi anda", style: const TextStyle(color: Colors.grey, fontSize: 11)),

//             const Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
//                   child: Text("Kuota: ${mitra.kuota}", style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (_) => DetailMitraPage(mitraId: mitra.id, distance: distance)));
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF4A60AA),
//                     minimumSize: const Size(80, 32),
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: const Text("Lamar", style: TextStyle(color: Colors.white, fontSize: 12)),
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

  
                                                    
                                   
                    
                    
                         
                         
                  
                     
  
                  

                
               
               
                 
                      
                     
  
                                
                         
                            
                               
                         
                        
                           
                     
               
                     
                      
                     
                     
                          
                         
                         
                        
                       
                            
                                
                        
                     
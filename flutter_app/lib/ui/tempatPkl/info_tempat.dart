import 'package:flutter/material.dart';
import 'package:flutter_app/core/api/client/placement_client.dart';
import 'package:flutter_app/core/api/dio_client.dart';
import 'package:flutter_app/data/models/response/placement_detail_response.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoTempatPage extends StatefulWidget {
  const InfoTempatPage({super.key});

  @override
  State<InfoTempatPage> createState() => _InfoTempatPageState();
}

class _InfoTempatPageState extends State<InfoTempatPage> {
  late PlacementClient _placementClient;
  PlacementDetailData? _placementData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _placementClient = PlacementClient(DioClient().dio);
    _loadPlacementData();
  }

  Future<void> _loadPlacementData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _placementClient.getPlacementDetail();

      if (response.success && response.data != null) {
        setState(() {
          _placementData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Gagal memuat data.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPlacementData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Coba Lagi',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A60AA),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final mitra = _placementData?.mitra;
    final pembimbing = _placementData?.pembimbing;

    return Stack(
      children: [
        // Gradient Header Background
        Container(
          height: 280,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4A60AA),
                Color(0xFF3D4F8C),
              ],
            ),
          ),
        ),

        // Safe Area content
        SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card (Company info)
                        _buildHeaderCard(mitra),

                        const SizedBox(height: 20),

                        // Quick Info Cards Row
                        _buildQuickInfoRow(mitra),

                        const SizedBox(height: 20),

                        // Address Section
                        _buildSectionCard(
                          title: 'Lokasi',
                          icon: Icons.location_on,
                          iconColor: const Color(0xFF4A60AA),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatAddress(mitra?.alamat),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (mitra?.alamat?.location != null)
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _openMaps(mitra?.alamat?.location),
                                    icon: const Icon(Icons.map,
                                        color: Color(0xFF4A60AA)),
                                    label: const Text('Buka di Maps',
                                        style: TextStyle(
                                            color: Color(0xFF4A60AA))),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      side: const BorderSide(
                                          color: Color(0xFF4A60AA)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // About Section
                        if (mitra?.deskripsi != null &&
                            mitra!.deskripsi!.isNotEmpty)
                          _buildSectionCard(
                            title: 'Tentang Tempat PKL',
                            icon: Icons.info_outline,
                            iconColor: Colors.blue,
                            child: Text(
                              mitra.deskripsi!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // PKL Period Section
                        _buildSectionCard(
                          title: 'Periode PKL',
                          icon: Icons.calendar_month,
                          iconColor: Colors.orange,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildPeriodItem(
                                  'Mulai',
                                  _formatDate(_placementData?.tglMulai),
                                  Colors.green,
                                ),
                              ),
                              Container(
                                height: 50,
                                width: 1,
                                color: Colors.grey[200],
                              ),
                              Expanded(
                                child: _buildPeriodItem(
                                  'Selesai',
                                  _formatDate(_placementData?.tglSelesai),
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Pembimbing Section
                        _buildSectionCard(
                          title: 'Pembimbing',
                          icon: Icons.person,
                          iconColor: Colors.purple,
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.person,
                                    color: Colors.purple, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pembimbing?.name ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (pembimbing?.email != null)
                                      Text(
                                        pembimbing!.email!,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (pembimbing?.phone != null)
                                IconButton(
                                  onPressed: () =>
                                      _makePhoneCall(pembimbing!.phone!),
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.phone,
                                        color: Colors.green, size: 20),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Status Section
                        _buildStatusCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Info Tempat PKL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadPlacementData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(PlacementMitraData? mitra) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Icon & Name
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A60AA), Color(0xFF3D4F8C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    const Icon(Icons.business, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mitra?.namaInstansi ?? 'Nama Instansi',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        mitra?.bidangUsaha ?? 'Bidang Usaha',
                        style: const TextStyle(
                          color: Color(0xFF4A60AA),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoRow(PlacementMitraData? mitra) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickInfoCard(
            icon: Icons.access_time,
            label: 'JAM KERJA',
            value:
                '${_formatTime(mitra?.jamMasuk)} - ${_formatTime(mitra?.jamPulang)}',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickInfoCard(
            icon: Icons.gps_fixed,
            label: 'RADIUS',
            value: '${mitra?.radiusMeter ?? '-'} meter',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPeriodItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _placementData?.status?.toLowerCase();
    Color statusColor;
    String statusText;
    IconData statusIcon;
    Color bgColor;

    switch (status) {
      case 'berjalan':
      case 'active':
        statusColor = Colors.green;
        statusText = 'Sedang Berjalan';
        statusIcon = Icons.play_circle_filled;
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 'selesai':
        statusColor = Colors.blue;
        statusText = 'Selesai';
        statusIcon = Icons.check_circle;
        bgColor = const Color(0xFFE3F2FD);
        break;
      case 'pending':
      case 'pengajuan':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        statusIcon = Icons.hourglass_empty;
        bgColor = const Color(0xFFFFF3E0);
        break;
      default:
        statusColor = Colors.grey;
        statusText = status ?? 'Tidak Diketahui';
        statusIcon = Icons.info_outline;
        bgColor = const Color(0xFFF5F5F5);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status PKL',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Methods ---
  String _formatAddress(dynamic alamat) {
    if (alamat == null) return 'Alamat tidak tersedia';
    String detail = alamat.detailAlamat ?? '';
    String kabupaten = alamat.kabupaten ?? '';

    if (detail.isEmpty && kabupaten.isEmpty) return 'Lokasi belum diatur';

    List<String> parts = [];
    if (detail.isNotEmpty) parts.add(detail);
    if (kabupaten.isNotEmpty) parts.add(kabupaten);

    return parts.join(', ');
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '--:--';
    // Handle HH:mm:ss format, return HH:mm
    if (time.length >= 5) {
      return time.substring(0, 5);
    }
    return time;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
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

  Future<void> _openMaps(String? location) async {
    if (location == null) return;
    try {
      final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$location');
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka maps')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat melakukan panggilan')),
        );
      }
    }
  }
}

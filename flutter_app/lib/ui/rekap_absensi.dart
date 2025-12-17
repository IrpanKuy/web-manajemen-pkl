import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../data/models/absensi_model.dart';
import 'package:logger/logger.dart';

class RekapAbsensi extends StatefulWidget {
  const RekapAbsensi({super.key});

  @override
  State<RekapAbsensi> createState() => _RekapAbsensiState();
}

class _RekapAbsensiState extends State<RekapAbsensi> {
  final HistoryService _historyService = HistoryService();
  final Logger _logger = Logger();

  bool _isLoading = true;
  List<Absensi> _absensis = [];
  AbsensiSummary? _summary;
  String? _errorMessage;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _historyService.getAbsensiHistory(
        month: _selectedMonth,
        year: _selectedYear,
      );
      setState(() {
        _absensis = result['data'];
        _summary = result['summary'];
        _isLoading = false;
      });
    } catch (e) {
      _logger.e(e);
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  String _getDayName(String dateStr) {
    // Basic day name implementation from timestamp
    // Ideal: Use intl DateFormat('EEEE')
    // Fallback: simple logic or just return default
    try {
      DateTime date = DateTime.parse(dateStr);
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      return days[date.weekday - 1];
    } catch (e) {
      return '';
    }
  }

  String _getDateDay(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return date.day.toString();
    } catch (e) {
      return '';
    }
  }
   String _getDateMonthShort(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      const months = ['JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'];
      return months[date.month - 1];
    } catch (e) {
      return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF9FAFB), // Light grey background
      body: Column(
        children: [
          _buildFilter(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
             Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!),
                    ElevatedButton(onPressed: _fetchData, child: const Text('Coba Lagi'))
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      _buildList(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1D3C8A), // Dark blue like image
          borderRadius: BorderRadius.circular(30),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedMonth,
            dropdownColor: const Color(0xFF1D3C8A),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text('${_getMonthName(index + 1)} $_selectedYear'),
              );
            }),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedMonth = val;
                });
                _fetchData();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_summary == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Hadir',
            _summary!.totalHadirCount.toString(),
            'Hari',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Terlambat',
            _summary!.telat.toString(),
            'Kali',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_absensis.isEmpty) {
      return const Center(child: Text("Tidak ada data absensi"));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _absensis.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _absensis[index];
        return _buildListItem(item);
      },
    );
  }

  Widget _buildListItem(Absensi item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Box
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7), // Light greyish blue
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  _getDateMonthShort(item.tanggal),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667085),
                  ),
                ),
                Text(
                  _getDateDay(item.tanggal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getDayName(item.tanggal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF101828),
                      ),
                    ),
                    _buildStatusBadge(item.statusKehadiran),
                  ],
                ),
                const SizedBox(height: 8),
                if (item.statusKehadiran == 'sakit' || item.statusKehadiran == 'izin')
                  Row(
                    children: [
                       Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                       const SizedBox(width: 4),
                       Expanded(child: Text("Sakit/Keterangan", style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                    ],
                  )
                else if (item.statusKehadiran == 'alpha')
                   Row(
                    children: [
                       Icon(Icons.cancel_outlined, size: 16, color: Colors.red[600]),
                       const SizedBox(width: 4),
                       Expanded(child: Text("Tanpa Keterangan", style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                    ],
                  )
                else 
                  Row(
                    children: [
                      _buildTimeItem(Icons.login, item.jamMasuk),
                      const SizedBox(width: 8),
                      const Text("•", style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      _buildTimeItem(Icons.logout, item.jamPulang),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeItem(IconData icon, String? time) {
    if (time == null) return const SizedBox.shrink();
    // Format time from HH:mm:ss to HH:mm
    String formatted = time;
    try {
       final parts = time.split(':');
       if (parts.length >= 2) {
         formatted = "${parts[0]}:${parts[1]}";
       }
    } catch (_) {}

    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          formatted,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status.toLowerCase()) {
      case 'hadir':
        bgColor = const Color(0xFFECFDF3); // Light Green
        textColor = const Color(0xFF027A48); // Green
        text = 'Hadir';
        break;
      case 'telat':
        bgColor = const Color(0xFFFEF0C7); // Light Yellow
        textColor = const Color(0xFFB54708); // Dark Orange
        text = 'Terlambat';
        break;
      case 'izin':
        bgColor = const Color(0xFFEFF8FF); // Light Blue
        textColor = const Color(0xFF175CD3); // Blue
        text = 'Izin';
        break;
      case 'sakit':
        bgColor = const Color(0xFFEFF8FF); // Light Blue (same as Izin for now)
        textColor = const Color(0xFF175CD3);
        text = 'Sakit';
        break;
      case 'alpha':
        bgColor = const Color(0xFFFEF3F2); // Light Red
        textColor = const Color(0xFFB42318); // Red
        text = 'Tidak Hadir';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

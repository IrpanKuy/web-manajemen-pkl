import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../data/models/jurnal_model.dart';
import 'package:logger/logger.dart';
import 'package:flutter_app/ui/jurnal/detail_jurnal_page.dart';

class RekapJurnal extends StatefulWidget {
  const RekapJurnal({super.key});

  @override
  State<RekapJurnal> createState() => _RekapJurnalState();
}

class _RekapJurnalState extends State<RekapJurnal> {
  final HistoryService _historyService = HistoryService();
  final Logger _logger = Logger();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Jurnal> _jurnals = [];
  List<Jurnal> _filteredJurnals = [];
  JurnalSummary? _summary;
  String? _errorMessage;

  int _selectedMonth = DateTime.now().month;
  final int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJurnals = _jurnals.where((item) {
        return item.judul.toLowerCase().contains(query) ||
            item.deskripsi.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _historyService.getJurnalHistory(
        month: _selectedMonth,
        year: _selectedYear,
      );
      setState(() {
        _jurnals = result['data'];
        _filteredJurnals = _jurnals;
        _summary = result['summary'];
        _isLoading = false;
      });
      // Re-apply search if any
      if (_searchController.text.isNotEmpty) {
        _onSearchChanged();
      }
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
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
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
      const months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MEI',
        'JUN',
        'JUL',
        'AGU',
        'SEP',
        'OKT',
        'NOV',
        'DES'
      ];
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
          'Riwayat Jurnal',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Jurnal (Not implemented in this turn)
        },
        backgroundColor: const Color(0xFF1D3C8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTopFilter(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari jurnal...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!),
                    ElevatedButton(
                        onPressed: _fetchData, child: const Text('Coba Lagi'))
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                child: _filteredJurnals.isEmpty
                    ? const Center(child: Text("Tidak ada data jurnal"))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredJurnals.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildListItem(_filteredJurnals[index]);
                        },
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedMonth,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('${_getMonthName(index + 1)} $_selectedYear'),
                      ],
                    ),
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
          Text(
            'Total: ${_summary?.totalJurnal ?? 0} Jurnal',
            style:
                TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(Jurnal item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailJurnalPage(jurnal: item),
          ),
        ).then((_) => _fetchData()); // Refresh after returning
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Date Box
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF101828),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _buildStatusBadge(item.status),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            // Komentar Pendamping
            if (item.hasKomentarPendamping) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF9333EA).withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.comment,
                        size: 16, color: Color(0xFF9333EA)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Komentar Pendamping:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9333EA),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.komentarPendamping!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B21A8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    // pending, disetujui, revisi
    switch (status.toLowerCase()) {
      case 'disetujui':
        bgColor = const Color(0xFFECFDF3);
        textColor = const Color(0xFF027A48);
        icon = Icons.check_circle;
        text = 'Disetujui';
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF0C7);
        textColor = const Color(0xFFB54708);
        icon = Icons.access_time_filled;
        text = 'Pending';
        break;
      case 'revisi':
        bgColor = const Color(0xFFFEF3F2);
        textColor = const Color(0xFFB42318);
        icon = Icons.edit;
        text = 'Perlu Revisi';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.help;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
                color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

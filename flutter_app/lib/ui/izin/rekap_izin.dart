import 'package:flutter/material.dart';
import '../../services/izin_service.dart';
import '../../data/models/izin_model.dart';
import 'form_izin.dart';
import 'package:logger/logger.dart';

class RekapIzin extends StatefulWidget {
  const RekapIzin({super.key});

  @override
  State<RekapIzin> createState() => _RekapIzinState();
}

class _RekapIzinState extends State<RekapIzin> {
  final IzinService _izinService = IzinService();
  final Logger _logger = Logger();

  bool _isLoading = true;
  List<Izin> _izins = [];
  String? _errorMessage;

  int _selectedMonth = DateTime.now().month;
  final int _selectedYear = DateTime.now().year;

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
      final result = await _izinService.getIzinHistory(
        month: _selectedMonth,
        year: _selectedYear,
      );
      setState(() {
        _izins = result;
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

  Future<void> _cancelIzin(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Izin?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Ya, Batalkan",
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _izinService.cancelIzin(id);
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Berhasil dibatalkan")));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  // Check if there is an permission starting Today
  bool get _hasIzinToday {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    return _izins.any((element) => element.tglMulai == todayStr);
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
      return DateTime.parse(dateStr).day.toString();
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
          'Riwayat Izin',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton(
        onPressed: _hasIzinToday
            ? null
            : () async {
                final res = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const FormIzin()));
                if (res == true) _fetchData();
              },
        backgroundColor: _hasIzinToday ? Colors.grey : const Color(0xFF1D3C8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                child: _izins.isEmpty
                    ? const Center(child: Text("Belum ada riwayat izin"))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _izins.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildListItem(_izins[index]);
                        },
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
          color: const Color(0xFF1D3C8A),
          borderRadius: BorderRadius.circular(30),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedMonth,
            dropdownColor: const Color(0xFF1D3C8A),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildListItem(Izin item) {
    return InkWell(
      onTap: () {
        // Detail / ReadOnly Form
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => FormIzin(izin: item)));
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    _getDateMonthShort(item.tglMulai),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667085),
                    ),
                  ),
                  Text(
                    _getDateDay(item.tglMulai),
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
                    "${item.durasiHari} Hari",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    item.keterangan,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(item.status),
                      if (item.status == 'pending')
                        TextButton(
                          onPressed: () => _cancelIzin(item.id),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 20),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Colors.red),
                          child: const Text("Batalkan",
                              style: TextStyle(fontSize: 12)),
                        )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui': // Backend might send either
        bgColor = const Color(0xFFECFDF3);
        textColor = const Color(0xFF027A48);
        text = 'Disetujui';
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF0C7);
        textColor = const Color(0xFFB54708);
        text = 'Pending';
        break;
      case 'rejected':
      case 'ditolak':
        bgColor = const Color(0xFFFEF3F2);
        textColor = const Color(0xFFB42318);
        text = 'Ditolak';
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
        style: TextStyle(
            color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../data/models/izin_model.dart';
import '../../services/izin_service.dart';

class FormIzin extends StatefulWidget {
  final Izin? izin; // If provided, ReadOnly mode
  const FormIzin({super.key, this.izin});

  @override
  State<FormIzin> createState() => _FormIzinState();
}

class _FormIzinState extends State<FormIzin> {
  final IzinService _izinService = IzinService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _keteranganController;
  DateTime? _tglMulai;
  DateTime? _tglSelesai;
  int _durasi = 0;
  File? _selectedFile;
  bool _isLoading = false;

  bool get _isReadOnly => widget.izin != null;

  @override
  void initState() {
    super.initState();
    _keteranganController =
        TextEditingController(text: widget.izin?.keterangan ?? '');

    if (widget.izin != null) {
      _tglMulai = DateTime.tryParse(widget.izin!.tglMulai);
      _tglSelesai = DateTime.tryParse(widget.izin!.tglSelesai);
      _durasi = widget.izin!.durasiHari;
    } else {
      _tglMulai = DateTime.now();
      _tglSelesai = DateTime.now();
      _durasi = 1;
    }
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  void _calculateDuration() {
    if (_tglMulai != null && _tglSelesai != null) {
      final diff = _tglSelesai!.difference(_tglMulai!).inDays;
      setState(() {
        _durasi = diff >= 0 ? diff + 1 : 0;
      });
    }
  }

  Future<void> _pickDate(bool isStart) async {
    if (_isReadOnly) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_tglMulai ?? DateTime.now())
          : (_tglSelesai ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _tglMulai = picked;
          // Ensure end date is not before start
          if (_tglSelesai != null && _tglSelesai!.isBefore(_tglMulai!)) {
            _tglSelesai = _tglMulai;
          }
        } else {
          _tglSelesai = picked;
          if (_tglMulai != null && _tglSelesai!.isBefore(_tglMulai!)) {
            _tglMulai = _tglSelesai;
          }
        }
        _calculateDuration();
      });
    }
  }

  Future<void> _pickFile() async {
    if (_isReadOnly) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tglMulai == null || _tglSelesai == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pilih tanggal")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _izinService.submitIzin(
        tglMulai: DateFormat('yyyy-MM-dd').format(_tglMulai!),
        tglSelesai: DateFormat('yyyy-MM-dd').format(_tglSelesai!),
        keterangan: _keteranganController.text,
        bukti: _selectedFile,
      );
      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isReadOnly ? 'Detail Izin' : 'Ajukan Izin',
            style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Tanggal Mulai"),
              _buildDatePicker(true),
              const SizedBox(height: 16),
              _buildLabel("Tanggal Selesai"),
              _buildDatePicker(false),
              const SizedBox(height: 16),
              Text("Durasi: $_durasi Hari",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 16),
              _buildLabel("Keterangan"),
              TextFormField(
                controller: _keteranganController,
                maxLines: 4,
                readOnly: _isReadOnly,
                decoration: InputDecoration(
                    hintText: "Alasan izin...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor:
                        _isReadOnly ? Colors.grey.shade100 : Colors.white),
                validator: (val) =>
                    val == null || val.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              _buildLabel("Bukti Pendukung (Surat Dokter/Lainnya)"),
              const SizedBox(height: 8),
              if (_isReadOnly && widget.izin?.buktiPath == null)
                const Text("Tidak ada bukti lampiran",
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic)),
              if (!_isReadOnly ||
                  (_isReadOnly && widget.izin?.buktiPath != null))
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedFile != null
                                ? _selectedFile!.path.split('/').last
                                : (_isReadOnly
                                    ? "Lihat Bukti (Klik tidak didukung di demo ini)"
                                    : "Upload File (PDF/JPG)"),
                            style: TextStyle(
                                color: _selectedFile != null
                                    ? Colors.black
                                    : Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_isReadOnly) ...[
                const SizedBox(height: 24),
                _buildLabel("Status"),
                Text(widget.izin!.status,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 32),
              if (!_isReadOnly)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D3C8A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Kirim Pengajuan",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildDatePicker(bool isStart) {
    final date = isStart ? _tglMulai : _tglSelesai;
    return InkWell(
      onTap: () => _pickDate(isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: _isReadOnly ? Colors.grey.shade100 : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat('dd MMMM yyyy').format(date)
                  : "Pilih Tanggal",
              style:
                  TextStyle(color: date != null ? Colors.black : Colors.grey),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

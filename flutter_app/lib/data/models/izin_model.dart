class Izin {
  final int id;
  final String tglMulai;
  final String tglSelesai;
  final int durasiHari;
  final String keterangan;
  final String? buktiPath;
  final String status; // pending, approved, rejected
  final String? komentar;

  Izin({
    required this.id,
    required this.tglMulai,
    required this.tglSelesai,
    required this.durasiHari,
    required this.keterangan,
    this.buktiPath,
    required this.status,
    this.komentar,
  });

  factory Izin.fromJson(Map<String, dynamic> json) {
    return Izin(
      id: json['id'],
      tglMulai: json['tgl_mulai'],
      tglSelesai: json['tgl_selesai'],
      durasiHari: json['durasi_hari'] ?? 1,
      keterangan: json['keterangan'] ?? '',
      buktiPath: json['bukti_path'],
      status: json['status'] ?? 'pending',
      komentar: json['komentar'],
    );
  }
}


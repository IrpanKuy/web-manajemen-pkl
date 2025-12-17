class Absensi {
  final int id;
  final String tanggal;
  final String? jamMasuk;
  final String? jamPulang;
  final String statusKehadiran; // hadir, telat, izin, sakit, alpha, pending

  Absensi({
    required this.id,
    required this.tanggal,
    this.jamMasuk,
    this.jamPulang,
    required this.statusKehadiran,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      id: json['id'],
      tanggal: json['tanggal'],
      jamMasuk: json['jam_masuk'],
      jamPulang: json['jam_pulang'],
      statusKehadiran: json['status_kehadiran'] ?? 'pending',
    );
  }
}

class AbsensiSummary {
  final int hadir;
  final int telat;
  final int sakit;
  final int izin;
  final int alpha;
  final int totalHadirCount;

  AbsensiSummary({
    required this.hadir,
    required this.telat,
    required this.sakit,
    required this.izin,
    required this.alpha,
    required this.totalHadirCount,
  });

  factory AbsensiSummary.fromJson(Map<String, dynamic> json) {
    return AbsensiSummary(
      hadir: json['hadir'] ?? 0,
      telat: json['telat'] ?? 0,
      sakit: json['sakit'] ?? 0,
      izin: json['izin'] ?? 0,
      alpha: json['alpha'] ?? 0,
      totalHadirCount: json['total_hadir_count'] ?? 0,
    );
  }
}


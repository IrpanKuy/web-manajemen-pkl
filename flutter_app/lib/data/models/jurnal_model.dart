class Jurnal {
  final int id;
  final String tanggal;
  final String judul;
  final String deskripsi;
  final String status; // pending, disetujui, revisi/ditolak

  Jurnal({
    required this.id,
    required this.tanggal,
    required this.judul,
    required this.deskripsi,
    required this.status,
  });

  factory Jurnal.fromJson(Map<String, dynamic> json) {
    return Jurnal(
      id: json['id'],
      tanggal: json['tanggal'],
      judul: json['judul'],
      deskripsi: json['deskripsi'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}

class JurnalSummary {
  final int totalJurnal;

  JurnalSummary({required this.totalJurnal});

  factory JurnalSummary.fromJson(Map<String, dynamic> json) {
    return JurnalSummary(
      totalJurnal: json['total_jurnal'] ?? 0,
    );
  }
}


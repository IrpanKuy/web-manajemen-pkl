class Jurnal {
  final int id;
  final String tanggal;
  final String judul;
  final String deskripsi;
  final String status; // pending, disetujui, revisi/ditolak
  final String? fotoKegiatan;
  final String? komentar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Jurnal({
    required this.id,
    required this.tanggal,
    required this.judul,
    required this.deskripsi,
    required this.status,
    this.fotoKegiatan,
    this.komentar,
    this.createdAt,
    this.updatedAt,
  });

  factory Jurnal.fromJson(Map<String, dynamic> json) {
    return Jurnal(
      id: json['id'],
      tanggal: json['tanggal'],
      judul: json['judul'],
      deskripsi: json['deskripsi'] ?? '',
      status: json['status'] ?? 'pending',
      fotoKegiatan: json['foto_kegiatan'],
      komentar: json['komentar'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal,
      'judul': judul,
      'deskripsi': deskripsi,
      'status': status,
      'foto_kegiatan': fotoKegiatan,
      'komentar': komentar,
    };
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

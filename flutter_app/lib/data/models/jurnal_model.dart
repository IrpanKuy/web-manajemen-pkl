class Jurnal {
  final int id;
  final String tanggal;
  final String judul;
  final String deskripsi;
  final String status; // pending, disetujui, revisi
  final String? fotoKegiatan;
  final String? alasanRevisiPembimbing;
  final String? komentarPendamping;
  final PendampingInfo? pendamping;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Jurnal({
    required this.id,
    required this.tanggal,
    required this.judul,
    required this.deskripsi,
    required this.status,
    this.fotoKegiatan,
    this.alasanRevisiPembimbing,
    this.komentarPendamping,
    this.pendamping,
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
      alasanRevisiPembimbing: json['alasan_revisi_pembimbing'],
      komentarPendamping: json['komentar_pendamping'],
      pendamping: json['pendamping'] != null
          ? PendampingInfo.fromJson(json['pendamping'])
          : null,
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
      'alasan_revisi_pembimbing': alasanRevisiPembimbing,
      'komentar_pendamping': komentarPendamping,
    };
  }

  bool get hasKomentarPendamping =>
      komentarPendamping != null && komentarPendamping!.isNotEmpty;
  
  bool get isRevisi => status.toLowerCase() == 'revisi';
  
  bool get isPending => status.toLowerCase() == 'pending';
  
  bool get isDisetujui => status.toLowerCase() == 'disetujui';
}

class PendampingInfo {
  final int id;
  final String name;

  PendampingInfo({required this.id, required this.name});

  factory PendampingInfo.fromJson(Map<String, dynamic> json) {
    return PendampingInfo(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class JurnalSummary {
  final int totalJurnal;
  final int denganKomentar;
  final int tanpaKomentar;

  JurnalSummary({
    required this.totalJurnal,
    this.denganKomentar = 0,
    this.tanpaKomentar = 0,
  });

  factory JurnalSummary.fromJson(Map<String, dynamic> json) {
    return JurnalSummary(
      totalJurnal: json['total_jurnal'] ?? 0,
      denganKomentar: json['dengan_komentar'] ?? 0,
      tanpaKomentar: json['tanpa_komentar'] ?? 0,
    );
  }
}



// enum
enum StatusAlat { tersedia, disewa, perbaikan }

// alat tidak tersedia
class AlatTidakTersediaException implements Exception {
  AlatTidakTersediaException(this.kodeAlat, this.statusSaatIni);
  final String kodeAlat;
  final StatusAlat statusSaatIni;

  @override
  String toString() =>
      'Alat "$kodeAlat" tidak bisa disewa (status: ${statusSaatIni.name})';
}

// mixin alat dan penyewaan
mixin Auditable {
  final List<String> riwayat = [];
  void catat(String peristiwa) => riwayat.add(peristiwa);
}

// penyewa biasa
class Penyewa {
  Penyewa({required this.nama, required this.noHp});
  final String nama;
  final String noHp;
  double get diskonPersen => 0;
}

// member
class Member extends Penyewa {
  Member({required super.nama, required super.noHp, required this.nomorMember});
  final String nomorMember;

  @override
  double get diskonPersen => 15;
}

// alat camping
class Alat with Auditable {
  Alat({
    required this.kode,
    required this.nama,
    required this.hargaPerHari,
    this.status = StatusAlat.tersedia,
  });

  final String kode;
  final String nama;
  final int hargaPerHari;
  StatusAlat status;

  // Nullable, terisi kalau alat ini pernah rusak
  String? catatanKerusakanTerakhir;

  void ubahStatus(StatusAlat baru, {String? catatan}) {
    status = baru;
    catat('Status jadi ${baru.name}${catatan != null ? ' — $catatan' : ''}');
    if (catatan != null) catatanKerusakanTerakhir = catatan;
  }
}

// transaksi penyewaan — komposisi dari Alat dan Penyewa
class Penyewaan with Auditable {
  Penyewaan._({
    required this.id,
    required this.alat,
    required this.penyewa,
    required this.lamaHari,
    this.tanggalKembali,
    this.catatanKerusakan,
  });

  // aturan "alat harus tersedia" tidak bisa dilanggar
  factory Penyewaan.buat({
    required String id,
    required Alat alat,
    required Penyewa penyewa,
    required int lamaHari,
  }) {
    if (alat.status != StatusAlat.tersedia) {
      throw AlatTidakTersediaException(alat.kode, alat.status);
    }
    alat.ubahStatus(StatusAlat.disewa);
    final p = Penyewaan._(id: id, alat: alat, penyewa: penyewa, lamaHari: lamaHari);
    p.catat('Penyewaan $id dibuat untuk ${penyewa.nama}');
    return p;
  }

  final String id;
  final Alat alat;
  final Penyewa penyewa;
  final int lamaHari;

  // Nullable selama alat belum dikembalikan
  DateTime? tanggalKembali;
  // Nullable karena tidak semua pengembalian membawa kerusakan
  String? catatanKerusakan;

  int get totalBiaya =>
      (lamaHari * alat.hargaPerHari * (1 - penyewa.diskonPersen / 100)).round();

  void kembalikan({String? kerusakan}) {
    tanggalKembali = DateTime.now();
    catatanKerusakan = kerusakan;
    alat.ubahStatus(
      kerusakan != null ? StatusAlat.perbaikan : StatusAlat.tersedia,
      catatan: kerusakan,
    );
    catat('Dikembalikan${kerusakan != null ? ' dengan kerusakan' : ''}');
  }

  // simulasi gateway pembayaran async yang bisa gagal
  Future<bool> prosesPembayaran({bool simulasikanGagal = false}) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (simulasikanGagal) throw StateError('gateway menolak transaksi');
      catat('Pembayaran $totalBiaya berhasil');
      return true;
    } catch (e) {
      catat('Pembayaran gagal: $e');
      return false;
    }
  }

  Penyewaan copyWith({DateTime? tanggalKembali, String? catatanKerusakan}) {
    return Penyewaan._(
      id: id,
      alat: alat,
      penyewa: penyewa,
      lamaHari: lamaHari,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
      catatanKerusakan: catatanKerusakan ?? this.catatanKerusakan,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kodeAlat': alat.kode,
        'penyewa': penyewa.nama,
        'lamaHari': lamaHari,
        'tanggalKembali': tanggalKembali?.toIso8601String(),
        'catatanKerusakan': catatanKerusakan,
      };

  factory Penyewaan.fromJson(Map<String, dynamic> json, {required Alat alat, required Penyewa penyewa}) {
    return Penyewaan._(
      id: json['id'] as String,
      alat: alat,
      penyewa: penyewa,
      lamaHari: json['lamaHari'] as int,
      tanggalKembali: json['tanggalKembali'] == null
          ? null
          : DateTime.parse(json['tanggalKembali'] as String),
      catatanKerusakan: json['catatanKerusakan'] as String?,
    );
  }
}

import 'package:penyewaan_alat_camping/model.dart';

Future<void> main() async {
  final tenda = Alat(kode: 'TND-01', nama: 'Tenda Dome', hargaPerHari: 50000);
  final sari = Member(nama: 'Sari', noHp: '0813-222', nomorMember: 'A-045');
  final budi = Penyewa(nama: 'Budi', noHp: '0812-111');

  // buat objek dan mengubahnya
  final sewa = Penyewaan.buat(id: 'SWA-001', alat: tenda, penyewa: sari, lamaHari: 3);
  print('Total biaya (member, diskon 15%): ${sewa.totalBiaya}');

  // Aturan dilanggar
  try {
    Penyewaan.buat(id: 'SWA-002', alat: tenda, penyewa: budi, lamaHari: 2);
  } on AlatTidakTersediaException catch (e) {
    print('Ditolak: $e');
  }

  // Async + try-catch
  await sewa.prosesPembayaran();
  final gagal = await sewa.prosesPembayaran(simulasikanGagal: true);
  print('Percobaan pembayaran kedua berhasil? $gagal');

  // Pengembalian dengan kerusakan
  sewa.kembalikan(kerusakan: 'Resleting macet');
  print('Status tenda: ${tenda.status.name}');

  // copyWith
  final salinan = sewa.copyWith(catatanKerusakan: 'Sudah diperbaiki');
  print('Asli: ${sewa.catatanKerusakan} | Salinan: ${salinan.catatanKerusakan}');

  // toJson / fromJson
  final json = sewa.toJson();
  print('JSON: $json');
  final dariJson = Penyewaan.fromJson(json, alat: tenda, penyewa: sari);
  print('Dari JSON, biaya: ${dariJson.totalBiaya}');

  // Riwayat dari mixin Auditable
  print('Riwayat tenda: ${tenda.riwayat}');
  print('Riwayat penyewaan: ${sewa.riwayat}');
}

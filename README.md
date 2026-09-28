Penyewaan Alat Camping

Model domain penyewaan alat camping: Penyewa/Member, Alat (barang yang disewakan), dan Penyewaan (transaksi yang
menghubungkan keduanya).

- Aturan yang ditegakkan: 
satu alat tidak bisa disewa dua kali sekaligus
(Penyewaan.buat melempar AlatTidakTersediaException kalau alat belum
tersedia), dan alat yang kembali rusak otomatis masuk status perbaikan,
bukan langsung tersedia lagi.

- Keputusan yang sempat diragukan: Member mau dibuat lewat komposisi (menyimpan Penyewa ke field), tapi karena seorang member adalah penyewa  hanya beda di besar diskon pewarisan
(Member extends Penyewa) dipilih agar Member bisa dipakai langsung
di mana pun Penyewa diharapkan.

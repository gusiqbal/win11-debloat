# Windows 11 debloat

Menu sederhana untuk mengurangi pemakaian RAM saat idle di Windows 11, tanpa mematikan fitur keamanan. Bisa dipakai di laptop mana pun dan di handheld seperti ROG Xbox Ally X.

## Cara pakai
1. Unduh repo ini: tombol **Code > Download ZIP**, lalu extract. Bisa juga dengan `git clone`.
2. Klik dua kali **run.cmd**, lalu klik **Yes** saat Windows meminta akses admin.
   Kalau muncul peringatan "Windows protected your PC", klik **More info > Run anyway**.
3. Pilih menu:

| Menu | Fungsi |
|---|---|
| 1 | Debloat. Membuat restore point dulu, lalu menghapus aplikasi dan mematikan proses background. Aman dijalankan ulang. |
| 2 | Menampilkan RAM yang dipakai dan 15 proses paling boros. |
| 3 | Opsional: gabungkan proses svchost (lihat di bawah). |
| 4 | Batalkan menu 3. |

4. Restart setelah menu 1 atau 3.

Tanpa run.cmd, jalankan dari Terminal (Admin) di folder ini:
```powershell
powershell -ExecutionPolicy Bypass -File .\debloat.ps1
```

## Yang diubah oleh menu 1
- **Restore point** dibuat lebih dulu. Kalau gagal, tidak ada yang diubah.
- **Aplikasi yang jalan di background dihapus:** Copilot, Teams, Phone Link, Cross Device, Widgets dan aplikasi Microsoft 365.
- **Aplikasi bawaan yang jarang dipakai dihapus:** News, Weather, Tips, Solitaire, Clipchamp, Outlook (baru), To Do, Power Automate, Dev Home, Family, Quick Assist dan Feedback Hub. Ini hanya menghemat penyimpanan, bukan RAM.
- **Edge** tidak lagi preload saat login dan tidak tetap jalan setelah ditutup. Edge akan menampilkan "managed by your organisation"; ini tidak berbahaya.
- **OneDrive** tidak lagi jalan otomatis. File hanya sinkron saat OneDrive dibuka.
- **Layanan telemetri** (DiagTrack) dimatikan.

## Yang tidak disentuh
- Keamanan: Defender, Firewall, Windows Update, SmartScreen, Memory Integrity dan UAC.
- Gaming: Xbox app, Game Bar, Gaming Services dan Microsoft Store.
- Driver, Armoury Crate dan Windows Search.

## Menu 3: gabungkan proses svchost
Di PC dengan RAM lebih dari 3,5 GB, Windows menjalankan setiap layanan dalam proses svchost sendiri. Menu 3 membuat Windows menggabungkannya seperti di PC dengan RAM kecil, sehingga RAM yang dipakai sedikit berkurang.

Risikonya: kalau satu layanan crash, layanan lain dalam grup yang sama ikut berhenti. Pakai menu 4 untuk kembali ke bawaan Windows.

## Cara membaca RAM
Buka Task Manager > Performance > Memory.
- **In use**: angka yang penting.
- **Cached**: RAM yang dipakai Windows supaya lebih cepat. Langsung dilepas saat aplikasi atau game butuh.
- **Hardware reserved**: RAM untuk GPU terintegrasi. Diatur di BIOS atau aplikasi bawaan pabrik, bukan lewat script ini.

RAM idle yang tinggi tidak mengurangi fps. Windows mengambil kembali memori dari aplikasi yang diam saat game membutuhkannya.

## Kalau ada masalah
- **Mengembalikan pengaturan:** tekan Win+R, ketik `rstrui`, lalu pilih restore point "Before debloat". Ini mengembalikan pengaturan dan layanan.
- **Aplikasi yang terhapus:** restore point tidak memasang ulang aplikasi, jadi pasang lagi dari Microsoft Store. Untuk Widgets, cari "Windows Web Experience Pack".
- **svchost:** pilih menu 4, lalu restart.

## Tips tambahan untuk handheld (ROG Xbox Ally X dan sejenisnya)
1. Aktifkan Xbox full screen experience saat startup di Settings > Gaming. Mode ini tidak memuat desktop Windows.
2. Matikan aplikasi startup yang tidak perlu di Settings > Apps > Startup (Steam, Epic, EA, Discord dan sejenisnya).
3. Mode daya di Armoury Crate SE: Turbo saat dicolok charger, Performance saat pakai baterai.
4. Turunkan resolusi render dan pakai upscaler (FSR atau XeSS) di mode Quality atau Balanced.
5. Batasi fps di 40, 45 atau 60. Layar dengan VRR terasa lebih halus dengan fps yang stabil.
6. Install game berat di SSD internal, bukan microSD.

**FSR 4.1 di ROG Xbox Ally X** (driver masih preview, langkah bisa berubah): aktifkan preview updates di Armoury Crate SE, install driver GPU terbaru, lalu nyalakan toggle FSR di Game Bar lewat tombol ROG. FSR 4.1 hanya jalan di game DirectX 12 yang sudah punya FSR 3.1 atau lebih baru. Turunkan preset satu tingkat untuk mengimbangi fps yang sedikit turun.

## Yang tidak disarankan
- **ISO Windows modifikasi** seperti Ghost Spectre: isinya tidak bisa diperiksa, beberapa versi menghapus Windows Security, dan pemakaiannya melanggar lisensi Microsoft.
- **AtlasOS:** harus install ulang Windows, dan versi lamanya mematikan proteksi keamanan CPU dan Memory Integrity.
- **Mematikan Memory Integrity:** fps naik sedikit, tapi perlindungan berkurang.
- **OptiScaler:** mengganti file DLL di folder game, sehingga bisa terdeteksi anti-cheat di game online.

# Laporan Eksperimen Notifikasi Berbasis Lifecycle

## Skenario Uji

### Eksperimen 1: Kondisi Foreground (Aplikasi Sedang Dibuka)

**Kondisi Aplikasi:** Aplikasi dibuka dan berada di halaman utama (Home View)

**Langkah Testing:**
1. Buka aplikasi Masjid Sabilillah
2. Pastikan aplikasi berada di halaman Home
3. Buka Firebase Console → Cloud Messaging
4. Kirim test notification dengan:
   - Title: "Pengumuman Sholat Jumat"
   - Body: "Sholat Jumat akan dilaksanakan pada pukul 12:00 WIB"
   - Custom data: `route=/pengumuman`, `type=pengumuman`

**Hasil:**
- ✅ Notifikasi muncul sebagai Heads-up Notification (banner di atas layar)
- ✅ Notifikasi mengeluarkan suara (default system sound)
- ✅ Payload data tercatat di log terminal
- ✅ Notifikasi tersimpan di riwayat

**Bukti Implementasi:**
- Screenshot: Notifikasi muncul sebagai heads-up notification
- Log Terminal: Menampilkan payload `{route: /pengumuman, type: pengumuman}`
- Tampilan Layar: Notifikasi muncul di atas aplikasi yang sedang dibuka

---

### Eksperimen 2: Kondisi Background (Aplikasi Di-minimize)

**Kondisi Aplikasi:** Aplikasi di-minimize (tekan tombol Home), tidak ditutup total

**Langkah Testing:**
1. Buka aplikasi
2. Tekan tombol Home untuk minimize aplikasi
3. Kirim notifikasi melalui Firebase Console dengan format yang sama
4. Klik notifikasi yang muncul di System Tray

**Hasil:**
- ✅ Notifikasi masuk ke System Tray
- ✅ Saat diklik, aplikasi terbuka kembali
- ✅ Aplikasi melakukan navigasi ke halaman /pengumuman (bukan Home)
- ✅ Notifikasi tersimpan di riwayat

**Bukti Implementasi:**
- Screenshot: Notifikasi di System Tray
- Log Terminal: Menampilkan "Notification tapped" dan "Navigated to: /pengumuman"
- Tampilan Layar: Aplikasi langsung terbuka di halaman Pengumuman

---

### Eksperimen 3: Kondisi Terminated (Aplikasi Ditutup Paksa/Kill)

**Kondisi Aplikasi:** Aplikasi ditutup sepenuhnya dari Recent Apps (swipe up/kill process)

**Langkah Testing:**
1. Tutup aplikasi sepenuhnya dari Recent Apps
2. Kirim notifikasi melalui Firebase Console
3. Klik notifikasi yang muncul

**Hasil:**
- ✅ Notifikasi tetap masuk meskipun aplikasi mati
- ✅ Saat diklik, aplikasi melakukan inisialisasi ulang
- ✅ Aplikasi tetap bisa menangkap data dari notifikasi
- ✅ Navigasi otomatis ke /pengumuman berhasil

**Bukti Implementasi:**
- Screenshot: Notifikasi muncul meskipun app ditutup
- Log Terminal: Menampilkan "Initial message found" dan proses inisialisasi
- Tampilan Layar: Aplikasi terbuka langsung di halaman Pengumuman

---

## Analisis Perbandingan Perilaku Sistem Operasi

### Android

**Foreground:**
- Notifikasi muncul sebagai Heads-up Notification (banner di atas)
- Menggunakan flutter_local_notifications untuk kontrol penuh
- Custom sound dapat dikonfigurasi melalui notification channel

**Background:**
- Notifikasi masuk ke System Tray
- FCM handle notification, lalu trigger local notification
- Deep linking bekerja dengan baik melalui intent filter

**Terminated:**
- FCM tetap mengirim notifikasi ke device
- getInitialMessage() menangkap notifikasi saat app dibuka
- Deep linking tetap berfungsi melalui initial message

### iOS (Jika diimplementasikan)

**Foreground:**
- Notifikasi muncul sebagai banner di atas
- Perlu permission explicit dari user
- Custom sound menggunakan file .caf

**Background:**
- Notifikasi masuk ke Notification Center
- FCM handle melalui background handler
- Deep linking melalui URL scheme

**Terminated:**
- FCM mengirim notifikasi ke APNs
- getInitialMessage() menangkap saat app launch
- Deep linking melalui URL scheme

---

## Kesimpulan

Implementasi Push Notification berhasil menangani ketiga kondisi lifecycle aplikasi:
1. **Foreground**: Notifikasi muncul sebagai heads-up dengan custom sound
2. **Background**: Notifikasi masuk ke system tray dan deep linking berfungsi
3. **Terminated**: Notifikasi tetap masuk dan deep linking bekerja saat app dibuka

Semua fitur menggunakan GetX sebagai state management dengan struktur modular (Controller, View, Service) sesuai requirement Modul 6.


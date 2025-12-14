# Dokumentasi Implementasi Push Notification - Modul 6

## Overview
Implementasi fitur Push Notification menggunakan Firebase Cloud Messaging (FCM) dan flutter_local_notifications dengan GetX sebagai state management.

## Struktur Implementasi

### 1. Service Layer
- **lib/data/services/notification_service.dart**: Service untuk handle FCM dan local notifications
  - Initialize Firebase Cloud Messaging
  - Initialize flutter_local_notifications
  - Handle foreground, background, dan terminated notifications
  - Custom sound support (dapat dikonfigurasi)

### 2. Controller Layer (GetX)
- **lib/presentation/controllers/notification_controller.dart**: Controller untuk manage state notifikasi
  - Manage notification history
  - Handle navigation dari notifikasi
  - Mark as read/unread
  - Delete notifications

### 3. View Layer
- **lib/presentation/screens/pengumuman_screen.dart**: Screen pengumuman dengan integrasi notifikasi
- **lib/presentation/screens/notification_history_screen.dart**: Screen untuk melihat riwayat notifikasi

## Setup Firebase

### 1. Buat Project di Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Buat project baru atau pilih project yang sudah ada
3. Tambahkan Android app dengan package name: `com.example.masjid_sabilillah`

### 2. Download google-services.json
1. Download file `google-services.json` dari Firebase Console
2. Letakkan file tersebut di: `android/app/google-services.json`

### 3. Konfigurasi Selesai
- File `android/app/build.gradle.kts` sudah dikonfigurasi
- File `android/settings.gradle.kts` sudah dikonfigurasi
- File `android/app/src/main/AndroidManifest.xml` sudah dikonfigurasi

## Testing Scenarios

### Eksperimen 1: Foreground (Aplikasi Sedang Dibuka)

**Langkah-langkah:**
1. Buka aplikasi dan biarkan di halaman utama (Home View)
2. Buka Firebase Console → Cloud Messaging → Send test message
3. Isi form:
   - **Title**: Pengumuman Masjid
   - **Text**: Ini adalah notifikasi test
   - **Additional options** → **Custom data**:
     ```
     key: route, value: /pengumuman
     key: type, value: pengumuman
     ```
4. Pilih device dengan FCM token (dapat dilihat di screen Pengumuman)
5. Klik "Test"

**Hasil yang Diharapkan:**
- ✅ Notifikasi muncul sebagai Heads-up Notification (banner di atas)
- ✅ Notifikasi mengeluarkan suara (default system sound)
- ✅ Log terminal menampilkan payload data yang diterima
- ✅ Notifikasi tersimpan di riwayat notifikasi

**Cek Log Terminal:**
```
NotificationService: Foreground message received
NotificationService: Message ID: [message_id]
NotificationService: Payload: {route: /pengumuman, type: pengumuman}
NotificationService: Title: Pengumuman Masjid
NotificationService: Body: Ini adalah notifikasi test
```

### Eksperimen 2: Background (Aplikasi Di-minimize)

**Langkah-langkah:**
1. Buka aplikasi
2. Tekan tombol Home pada HP (aplikasi berjalan di background, tidak ditutup total)
3. Kirim notifikasi melalui Firebase Console dengan format yang sama seperti Eksperimen 1
4. Klik notifikasi yang muncul di System Tray

**Hasil yang Diharapkan:**
- ✅ Notifikasi masuk ke System Tray
- ✅ Saat notifikasi diklik, aplikasi terbuka kembali
- ✅ Aplikasi melakukan navigasi ke halaman spesifik (/pengumuman), bukan sekadar membuka halaman Home
- ✅ Notifikasi tersimpan di riwayat

**Cek Log Terminal:**
```
NotificationService: Notification tapped
NotificationService: Message data: {route: /pengumuman, type: pengumuman}
Handling notification navigation with data: {route: /pengumuman, type: pengumuman}
Navigated to: /pengumuman
```

### Eksperimen 3: Terminated (Aplikasi Ditutup Paksa/Kill)

**Langkah-langkah:**
1. Tutup aplikasi sepenuhnya dari Recent Apps (Swipe up/Kill process)
2. Kirim notifikasi melalui Firebase Console dengan format yang sama
3. Klik notifikasi yang muncul

**Hasil yang Diharapkan:**
- ✅ Notifikasi tetap masuk meskipun aplikasi mati
- ✅ Saat notifikasi diklik, aplikasi melakukan proses inisialisasi ulang
- ✅ Aplikasi tetap bisa menangkap data dari notifikasi tersebut untuk navigasi otomatis
- ✅ Navigasi ke halaman spesifik (/pengumuman) berhasil

**Cek Log Terminal:**
```
main: Firebase initialized
main: NotificationService initialized
NotificationService: Initial message found: [message_id]
NotificationService: Initial message data: {route: /pengumuman, type: pengumuman}
Handling notification navigation with data: {route: /pengumuman, type: pengumuman}
Navigated to: /pengumuman
```

## Format Data Notifikasi

Untuk navigasi otomatis, gunakan custom data berikut di Firebase Console:

### Navigasi ke Pengumuman
```
key: route, value: /pengumuman
key: type, value: pengumuman
```

### Navigasi ke Donasi
```
key: route, value: /donasi
key: type, value: donasi
```

### Navigasi ke Jadwal Sholat
```
key: route, value: /jadwal
key: type, value: jadwal
```

## Fitur yang Diimplementasikan

### ✅ Foreground Notifications
- Heads-up notification dengan flutter_local_notifications
- Custom sound support (dapat dikonfigurasi di assets/sounds/)
- Log payload data

### ✅ Background Notifications
- Notifikasi masuk ke System Tray
- Deep linking saat notifikasi diklik
- Navigasi otomatis ke halaman spesifik

### ✅ Terminated Notifications
- Notifikasi tetap masuk saat app ditutup
- Inisialisasi ulang saat app dibuka dari notifikasi
- Deep linking berfungsi dengan baik

### ✅ Notification History
- Riwayat semua notifikasi
- Mark as read/unread
- Delete notifications
- Unread count badge

### ✅ GetX State Management
- NotificationController menggunakan GetX
- Reactive UI dengan Obx
- Modular structure (Controller, View, Service)

## Custom Sound (Opsional)

Untuk menggunakan custom sound:
1. Letakkan file sound di `assets/sounds/notification_sound.mp3` (Android) atau `.caf` (iOS)
2. Uncomment baris di `notification_service.dart`:
   ```dart
   // Android
   sound: const RawResourceAndroidNotificationSound('notification_sound'),
   
   // iOS
   sound: 'notification_sound.caf',
   ```

## Troubleshooting

### Notifikasi tidak muncul
1. Pastikan `google-services.json` sudah ada di `android/app/`
2. Pastikan permission notification sudah diberikan
3. Cek log terminal untuk error messages
4. Pastikan FCM token valid (lihat di screen Pengumuman)

### Navigasi tidak bekerja
1. Pastikan custom data `route` atau `type` sudah diisi dengan benar
2. Cek log terminal untuk melihat data yang diterima
3. Pastikan route yang digunakan sudah terdaftar di `main.dart`

### App crash saat initialize
1. Pastikan semua dependencies sudah di-install: `flutter pub get`
2. Pastikan minSdk sudah di-set ke 21 atau lebih tinggi
3. Pastikan Google Services plugin sudah ditambahkan

## Catatan Penting

- FCM Token dapat dilihat di screen Pengumuman
- Notifikasi history disimpan secara lokal menggunakan SharedPreferences
- GetX digunakan untuk state management notifikasi
- go_router digunakan untuk navigation
- Provider tetap digunakan untuk state management yang sudah ada (Theme, Auth)


// lib/presentation/screens/pengumuman_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_sabilillah/presentation/controllers/notification_controller.dart';

class PengumumanScreen extends StatelessWidget {
  const PengumumanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
        actions: [
          Obx(() => Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => context.go('/notifikasi'),
                  ),
                  if (controller.unreadCount.value > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          controller.unreadCount.value > 99
                              ? '99+'
                              : controller.unreadCount.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Notifikasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Text(
                          'FCM Token: ${controller.fcmToken.value.isEmpty ? "Loading..." : controller.fcmToken.value.substring(0, 50) + "..."}',
                          style: const TextStyle(fontSize: 12),
                        )),
                    const SizedBox(height: 8),
                    const Text(
                      'Gunakan token ini untuk mengirim notifikasi melalui Firebase Console.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (controller.fcmToken.value.isNotEmpty) {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('FCM Token'),
                              content: SelectableText(controller.fcmToken.value),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Salin Token'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Pengumuman List
            Text(
              'Pengumuman Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Sample pengumuman items
            _buildPengumumanCard(
              context,
              title: 'Pengumuman Sholat Jumat',
              description: 'Sholat Jumat akan dilaksanakan pada pukul 12:00 WIB. Jangan lupa hadir tepat waktu.',
              date: '14 Desember 2024',
              icon: Icons.mosque,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildPengumumanCard(
              context,
              title: 'Penggalangan Donasi',
              description: 'Masjid Sabilillah sedang menggalang donasi untuk renovasi. Bantuan Anda sangat berarti.',
              date: '13 Desember 2024',
              icon: Icons.volunteer_activism,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildPengumumanCard(
              context,
              title: 'Kajian Rutin',
              description: 'Kajian rutin setiap Sabtu malam pukul 19:00 WIB. Semua jamaah diundang untuk hadir.',
              date: '12 Desember 2024',
              icon: Icons.menu_book,
              color: Colors.green,
            ),
            
            const SizedBox(height: 24),
            
            // Testing Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Testing Notifikasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Untuk menguji notifikasi, kirim notifikasi melalui Firebase Console dengan format berikut:',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Title: Pengumuman Masjid',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                          Text(
                            'Body: Isi pengumuman Anda',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Data (optional):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            '  route: /pengumuman',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                          Text(
                            '  type: pengumuman',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPengumumanCard(
    BuildContext context, {
    required String title,
    required String description,
    required String date,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


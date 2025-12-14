// lib/presentation/screens/notification_history_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_sabilillah/presentation/controllers/notification_controller.dart';
import 'package:intl/intl.dart';

class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Notifikasi'),
        actions: [
          Obx(() => controller.notifications.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.check_all),
                  tooltip: 'Tandai semua sudah dibaca',
                  onPressed: () => controller.markAllAsRead(),
                )
              : const SizedBox.shrink()),
          Obx(() => controller.notifications.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Hapus semua',
                  onPressed: () async {
                    final confirm = await Get.dialog<bool>(
                      AlertDialog(
                        title: const Text('Hapus Semua Notifikasi?'),
                        content: const Text(
                            'Apakah Anda yakin ingin menghapus semua notifikasi?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      controller.clearAll();
                    }
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada notifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            final isRead = notification.isRead;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: isRead ? 1 : 3,
              color: isRead
                  ? null
                  : primaryColor.withOpacity(0.05),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: CircleAvatar(
                  backgroundColor: isRead
                      ? Colors.grey[300]
                      : primaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.notifications,
                    color: isRead ? Colors.grey[600] : primaryColor,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    color: isRead ? Colors.grey[700] : Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: isRead ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(isRead ? 'Tandai belum dibaca' : 'Tandai sudah dibaca'),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () => controller.markAsRead(notification.id),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () => controller.deleteNotification(notification.id),
                        );
                      },
                    ),
                  ],
                ),
                onTap: () {
                  if (!isRead) {
                    controller.markAsRead(notification.id);
                  }
                  // Navigate based on notification data
                  if (notification.data != null) {
                    final route = notification.data!['route'] as String?;
                    final type = notification.data!['type'] as String?;
                    if (route != null && route.isNotEmpty) {
                      context.go(route);
                    } else if (type != null) {
                      _navigateByType(context, type);
                    }
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(timestamp);
    }
  }

  void _navigateByType(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'pengumuman':
      case 'announcement':
        context.go('/pengumuman');
        break;
      case 'donasi':
      case 'donation':
        context.go('/donasi');
        break;
      case 'jadwal':
      case 'prayer':
      case 'sholat':
        context.go('/jadwal');
        break;
      default:
        context.go('/pengumuman');
    }
  }
}


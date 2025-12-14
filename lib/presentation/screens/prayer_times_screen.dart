// lib/presentation/screens/prayer_times_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_sabilillah/core/constants/app_colors.dart';
import 'package:masjid_sabilillah/data/models/prayer_time_model.dart';
import 'package:masjid_sabilillah/data/services/api_service.dart';
import 'package:masjid_sabilillah/data/services/local_storage_service.dart';
import 'package:masjid_sabilillah/presentation/widgets/common/blue_card.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil kota dari penyimpanan lokal
    final futurePrayer = () async {
      final city = await LocalStorageService().getCity();
      return ApiService().getPrayerTimes(city: city);
    }();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          IconButton(
            onPressed: () => context.go('/'), // Kembali ke Home
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: FutureBuilder<PrayerTime>(
        future: futurePrayer,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.lightPrimary));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: AppColors.lightPrimary, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat jadwal sholat',
                    style: TextStyle(color: AppColors.lightPrimary, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final prayer = snapshot.data!;
            final prayerList = prayer.prayerList;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hari ini: ${prayer.tanggal}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(prayerList.length, (index) {
                    final item = prayerList[index];
                    return BlueCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name']!,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            item['time']!,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Data tidak tersedia'));
          }
        },
      ),
    );
  }
}
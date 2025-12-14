class PrayerTime {
  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final String tanggal;

  PrayerTime({
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.tanggal,
  });

  // Helper untuk UI
  List<Map<String, String>> get prayerList => [
        {'name': 'Subuh', 'time': subuh},
        {'name': 'Dzuhur', 'time': dzuhur},
        {'name': 'Ashar', 'time': ashar},
        {'name': 'Maghrib', 'time': maghrib},
        {'name': 'Isya', 'time': isya},
      ];
}
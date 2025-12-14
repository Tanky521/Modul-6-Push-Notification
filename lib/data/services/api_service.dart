import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:masjid_sabilillah/data/models/prayer_time_model.dart';

class ApiService {
  Future<PrayerTime> getPrayerTimes({
    String city = 'Surabaya',
    String country = 'ID',
  }) async {
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=5&timeformat=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final d = data['data'];
      final t = d['timings'];
      final date = d['date']['gregorian']['date'];

      return PrayerTime(
        tanggal: date,
        subuh: t['Fajr'],
        dzuhur: t['Dhuhr'],
        ashar: t['Asr'],
        maghrib: t['Maghrib'],
        isya: t['Isha'],
      );
    } else {
      throw Exception('Gagal mengambil jadwal sholat');
    }
  }
}
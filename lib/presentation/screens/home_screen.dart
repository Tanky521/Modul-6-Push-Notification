// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:masjid_sabilillah/presentation/widgets/animated/fade_in_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // Foto Background Masjid
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1590658268037-6bf12165a62f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: primaryColor.withOpacity(0.3)),
              errorWidget: (context, url, error) =>
                  Container(color: primaryColor.withOpacity(0.3)),
            ),
          ),

          // Overlay Gradien (biru → hitam transparan)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.7),
                    Colors.black.withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Konten Utama (scrollable)
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top + 40,
                      bottom: 40,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        // Logo Masjid
                        Container(
                          width: isTablet ? 140 : 120,
                          height: isTablet ? 140 : 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mosque,
                            color: primaryColor,
                            size: isTablet ? 72 : 60,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Judul
                        Text(
                          'Masjid Sabilillah',
                          style: TextStyle(
                            fontSize: isTablet ? 36 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tempat Beribadah & Silaturahmi',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Daftar Fitur
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        _buildFeatureCard(
                          context,
                          icon: Icons.alarm,
                          title: 'Jadwal Sholat',
                          route: '/jadwal',
                          delay: 300,
                          color: Colors.blue[300]!,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          icon: Icons.location_on,
                          title: 'Lokasi Masjid',
                          route: '/lokasi',
                          delay: 400,
                          color: Colors.green[300]!,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          icon: Icons.volunteer_activism,
                          title: 'Donasi',
                          route: '/donasi',
                          delay: 500,
                          color: Colors.orange[300]!,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context,
                          icon: Icons.notifications_active,
                          title: 'Pengumuman',
                          route: '/pengumuman',
                          delay: 600,
                          color: Colors.purple[300]!,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),

          // Ikon Pengaturan (⚙️) - Pojok Kanan Atas (di atas semua element)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  debugPrint('DEBUG: Settings button pressed');
                  context.go('/pengaturan');
                },
                icon: const Icon(Icons.settings),
                color: Colors.white,
                iconSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required int delay,
    required Color color,
  }) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return FadeInWidget(
      delay: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: () => context.go(route),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]?.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: isTablet ? 30 : 26),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: primaryColor.withOpacity(0.6),
                size: isTablet ? 20 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

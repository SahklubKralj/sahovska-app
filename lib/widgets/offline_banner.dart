import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class OfflineBanner extends StatelessWidget {
  final Widget child;
  final bool showConnectionQuality;

  const OfflineBanner({
    Key? key,
    required this.child,
    this.showConnectionQuality = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, _) {
        return Column(
          children: [
            if (!connectivityService.isOnline)
              _buildOfflineBanner(context),
            if (showConnectionQuality && connectivityService.isOnline)
              _buildConnectionQualityBanner(context, connectivityService),
            Expanded(child: child),
          ],
        );
      },
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.warning,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nema internet konekcije. Prikazuje se offline sadržaj.',
                style: AppTextStyles.withColor(
                  AppTextStyles.bodySmall,
                  Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _showOfflineInfo(context),
              child: Text(
                'Info',
                style: AppTextStyles.withColor(
                  AppTextStyles.labelSmall,
                  Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionQualityBanner(
      BuildContext context, ConnectivityService service) {
    return FutureBuilder<ConnectionQuality>(
      future: service.getConnectionQuality(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == ConnectionQuality.good) {
          return const SizedBox.shrink();
        }

        final quality = snapshot.data!;
        Color bannerColor;
        IconData icon;

        switch (quality) {
          case ConnectionQuality.medium:
            bannerColor = AppColors.info;
            icon = Icons.signal_wifi_4_bar;
            break;
          case ConnectionQuality.poor:
            bannerColor = AppColors.warning;
            icon = Icons.wifi_off;
            break;
          default:
            return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: bannerColor,
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                quality.displayName,
                style: AppTextStyles.withColor(
                  AppTextStyles.bodySmall,
                  Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOfflineInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline režim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trenutno ste offline. Možete:',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildOfflineFeature('📖', 'Čitati prethodno učitana obaveštenja'),
            _buildOfflineFeature('💾', 'Kreirati draft obaveštenja (admini)'),
            _buildOfflineFeature('⚙️', 'Menjati podešavanja aplikacije'),
            const SizedBox(height: 12),
            const Text(
              'Kada se povežete na internet, podaci će se automatski sinhronizovati.',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Razumem'),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineFeature(String emoji, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// Connectivity Indicator Widget
class ConnectivityIndicator extends StatelessWidget {
  final bool showLabel;

  const ConnectivityIndicator({
    Key? key,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, _) {
        if (connectivityService.isOnline) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi,
                color: AppColors.success,
                size: 16,
              ),
              if (showLabel) ...[
                const SizedBox(width: 4),
                Text(
                  'Online',
                  style: AppTextStyles.withColor(
                    AppTextStyles.labelSmall,
                    AppColors.success,
                  ),
                ),
              ],
            ],
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off,
                color: AppColors.warning,
                size: 16,
              ),
              if (showLabel) ...[
                const SizedBox(width: 4),
                Text(
                  'Offline',
                  style: AppTextStyles.withColor(
                    AppTextStyles.labelSmall,
                    AppColors.warning,
                  ),
                ),
              ],
            ],
          );
        }
      },
    );
  }
}
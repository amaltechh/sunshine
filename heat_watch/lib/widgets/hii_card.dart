import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/heat_inequality_index.dart';
import '../theme/app_colors.dart';

class HIICard extends StatelessWidget {
  final HeatInequalityIndex hii;
  final int rank;
  final VoidCallback? onTap;

  const HIICard({
    super.key,
    required this.hii,
    required this.rank,
    this.onTap,
  });

  Color get _riskColor {
    switch (hii.riskLevel) {
      case RiskLevel.extreme:
        return AppColors.darkRed;
      case RiskLevel.high:
        return AppColors.red;
      case RiskLevel.moderate:
        return AppColors.orange;
      case RiskLevel.low:
        return AppColors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _riskColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(12), // Reduced from 16 to 12
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank Badge
                Container(
                  width: 36, // Reduced from 40
                  height: 36, // Reduced from 40
                  decoration: BoxDecoration(
                    color: _riskColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: _riskColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Ward Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hii.wardName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hii.riskLevelText,
                        style: TextStyle(
                          color: _riskColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // HII Score
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _riskColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hii.overallScore.toStringAsFixed(1),
                    style: TextStyle(
                      color: _riskColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Reduced from 16 to 10
            // Metrics Row
            Row(
              children: [
                _MetricChip(
                  icon: Icons.thermostat,
                  label: '${hii.temperature.toStringAsFixed(1)}°C',
                  color: AppColors.red,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  icon: Icons.people,
                  label:
                      '${(hii.populationDensity / 1000).toStringAsFixed(1)}k/km²',
                  color: AppColors.orange,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  icon: Icons.park,
                  label: '${hii.greenCover.toStringAsFixed(0)}% green',
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.1, end: 0, duration: 300.ms);
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

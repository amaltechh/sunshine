import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/heat_provider.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/hii_card.dart';
import '../theme/app_colors.dart';
import '../models/heat_inequality_index.dart';

class InequalityScreen extends StatelessWidget {
  const InequalityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Heat Inequality Index'),
        ),
        body: Consumer<HeatProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.cyan),
              );
            }

            final hiiList = provider.hiiData;

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Who Suffers Most?',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 6), // Reduced for tighter fit
                        Text(
                          'Wards ranked by vulnerability to heat stress',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),

                        // Risk Distribution
                        _RiskDistributionBar(hiiList: hiiList),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // HII List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final hii = hiiList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HIICard(
                            hii: hii,
                            rank: index + 1,
                            onTap: () => _showDetailSheet(context, hii),
                          ),
                        );
                      },
                      childCount: hiiList.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, HeatInequalityIndex hii) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20), // Reduced from 24
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hii.wardName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRiskColor(hii).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hii.riskLevelText,
                    style: TextStyle(
                      color: _getRiskColor(hii),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.thermostat,
              label: 'Day Temperature',
              value: '${hii.temperature.toStringAsFixed(1)}°C',
              color: AppColors.red,
            ),
            _DetailRow(
              icon: Icons.nightlight,
              label: 'Night Temperature',
              value: '${hii.nightTemperature.toStringAsFixed(1)}°C',
              color: AppColors.orange,
            ),
            _DetailRow(
              icon: Icons.people,
              label: 'Population Density',
              value:
                  '${(hii.populationDensity / 1000).toStringAsFixed(1)}k/km²',
              color: AppColors.cyan,
            ),
            _DetailRow(
              icon: Icons.elderly,
              label: 'Vulnerable Population',
              value: '${hii.vulnerablePopulation.toStringAsFixed(1)}%',
              color: AppColors.warning,
            ),
            _DetailRow(
              icon: Icons.park,
              label: 'Green Cover',
              value: '${hii.greenCover.toStringAsFixed(1)}%',
              color: AppColors.success,
            ),
            _DetailRow(
              icon: Icons.local_hospital,
              label: 'Hospital Access',
              value: '${(hii.hospitalAccess * 100).toStringAsFixed(0)}%',
              color: AppColors.info,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/simulation');
                },
                child: const Text('Simulate Intervention'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(HeatInequalityIndex hii) {
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
}

class _RiskDistributionBar extends StatelessWidget {
  final List<HeatInequalityIndex> hiiList;

  const _RiskDistributionBar({required this.hiiList});

  @override
  Widget build(BuildContext context) {
    final extreme =
        hiiList.where((h) => h.riskLevel == RiskLevel.extreme).length;
    final high = hiiList.where((h) => h.riskLevel == RiskLevel.high).length;
    final moderate =
        hiiList.where((h) => h.riskLevel == RiskLevel.moderate).length;
    final low = hiiList.where((h) => h.riskLevel == RiskLevel.low).length;
    final total = hiiList.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Risk Distribution',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (extreme > 0)
                Expanded(
                  flex: extreme,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.darkRed,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(4)),
                    ),
                  ),
                ),
              if (high > 0)
                Expanded(
                  flex: high,
                  child: Container(
                    height: 8,
                    color: AppColors.red,
                  ),
                ),
              if (moderate > 0)
                Expanded(
                  flex: moderate,
                  child: Container(
                    height: 8,
                    color: AppColors.orange,
                  ),
                ),
              if (low > 0)
                Expanded(
                  flex: low,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.cyan,
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(4)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _RiskLegend(
                  color: AppColors.darkRed,
                  label: 'Extreme',
                  count: extreme,
                  total: total),
              _RiskLegend(
                  color: AppColors.red,
                  label: 'High',
                  count: high,
                  total: total),
              _RiskLegend(
                  color: AppColors.orange,
                  label: 'Moderate',
                  count: moderate,
                  total: total),
              _RiskLegend(
                  color: AppColors.cyan,
                  label: 'Low',
                  count: low,
                  total: total),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskLegend extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int total;

  const _RiskLegend({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count ($percentage%)',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // Reduced from 16 to 8
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

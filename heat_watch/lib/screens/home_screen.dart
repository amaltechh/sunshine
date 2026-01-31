import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/heat_provider.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/stat_card.dart';
import '../theme/app_colors.dart';
import '../models/heat_inequality_index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeatProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Column(
            children: [
              const Text('Heat Watch'),
              Text(
                'Urban Heat Intelligence',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<HeatProvider>().refreshData();
              },
            ),
          ],
        ),
        body: Consumer<HeatProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.cyan),
                    const SizedBox(height: 16),
                    Text(
                      'Loading heat data...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.danger),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.refreshData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final hottestWard = provider.hottestWard;
            final mostVulnerable = provider.mostVulnerableWard;

            return RefreshIndicator(
              onRefresh: provider.refreshData,
              color: AppColors.cyan,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Text(
                    'City Overview',
                    style: Theme.of(context).textTheme.displaySmall,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Real-time heat inequality analysis for Delhi NCR',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 24),

                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      StatCard(
                        title: 'Avg Temperature',
                        value: provider.avgCityTemperature.toStringAsFixed(1),
                        unit: '°C',
                        icon: Icons.thermostat,
                        gradientColors: const [AppColors.orange, AppColors.red],
                        subtitle: 'CITY AVG',
                      ),
                      StatCard(
                        title: 'Hottest Ward',
                        value:
                            hottestWard?.temperature.toStringAsFixed(1) ?? '--',
                        unit: '°C',
                        icon: Icons.local_fire_department,
                        gradientColors: const [
                          AppColors.red,
                          AppColors.darkRed
                        ],
                        subtitle: hottestWard?.wardName ?? 'N/A',
                      ),
                      StatCard(
                        title: 'High Risk Zones',
                        value: provider.hiiData
                            .where((h) =>
                                h.riskLevel == RiskLevel.extreme ||
                                h.riskLevel == RiskLevel.high)
                            .length
                            .toString(),
                        unit: 'wards',
                        icon: Icons.warning_amber,
                        gradientColors: const [
                          AppColors.orange,
                          AppColors.warning
                        ],
                      ),
                      StatCard(
                        title: 'Most Vulnerable',
                        value:
                            mostVulnerable?.overallScore.toStringAsFixed(0) ??
                                '--',
                        unit: 'HII',
                        icon: Icons.people,
                        gradientColors: const [
                          AppColors.cyan,
                          AppColors.coolBlue
                        ],
                        subtitle: mostVulnerable?.wardName ?? 'N/A',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Critical Zones Alert
                  if (mostVulnerable != null &&
                      mostVulnerable.riskLevel == RiskLevel.extreme)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.danger.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning,
                              color: AppColors.danger, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CRITICAL HEAT ALERT',
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${mostVulnerable.wardName} is experiencing extreme heat conditions',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake(duration: 600.ms, delay: 800.ms),

                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 16),

                  _QuickActionButton(
                    icon: Icons.map,
                    title: 'View Heat Map',
                    subtitle: 'Interactive city heat visualization',
                    onTap: () => Navigator.pushNamed(context, '/map'),
                  ),

                  const SizedBox(height: 12),

                  _QuickActionButton(
                    icon: Icons.analytics,
                    title: 'Inequality Analysis',
                    subtitle: 'See Heat Inequality Index rankings',
                    onTap: () => Navigator.pushNamed(context, '/inequality'),
                  ),

                  const SizedBox(height: 12),

                  _QuickActionButton(
                    icon: Icons.eco,
                    title: 'Simulate Interventions',
                    subtitle: 'Test tree planting & cool roof impact',
                    onTap: () => Navigator.pushNamed(context, '/simulation'),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.cyan, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}

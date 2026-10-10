import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:swift_rescue_admin/ui/widgets/glass_card.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  Future<Map<String, dynamic>> _fetchMetrics() async {
    final client = Supabase.instance.client;
    
    final motoristsRes = await client.from('profiles').select('*').eq('role', 'motorist').count(CountOption.exact);
    final driversRes = await client.from('profiles').select('*').eq('role', 'provider').count(CountOption.exact);
    final shopsRes = await client.from('profiles').select('*').eq('role', 'repair_shop').count(CountOption.exact);
    final ticketsRes = await client.from('support_tickets').select('*').eq('status', 'Open').count(CountOption.exact);
    final jobsRes = await client.from('jobs').select('service_type, lat, lng');

    String topService = 'N/A';
    String topLocation = 'N/A';
    int maxCount = 0;

    if (jobsRes.isNotEmpty) {
      final counts = <String, int>{};
      for (var job in jobsRes) {
        final st = job['service_type'] as String? ?? 'Unknown';
        counts[st] = (counts[st] ?? 0) + 1;
      }
      
      for (var entry in counts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          topService = entry.key;
        }
      }
      
      // Find a location associated with this top service (just take the first one or an average)
      final topJobs = jobsRes.where((j) => j['service_type'] == topService).toList();
      if (topJobs.isNotEmpty && topJobs.first['lat'] != null) {
        topLocation = '\${topJobs.first['lat'].toStringAsFixed(3)}, \${topJobs.first['lng'].toStringAsFixed(3)}';
      }
    }

    return {
      'motorists': motoristsRes.count,
      'drivers': driversRes.count,
      'shops': shopsRes.count,
      'openTickets': ticketsRes.count,
      'topService': topService,
      'topLocation': topLocation,
    };
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int axisCount = width < 600 ? 1 : width < 1000 ? 2 : 4;
    double aspectRatio = width < 600 ? 2.5 : 1.8;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard Overview', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 32),
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchMetrics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)));
                }
                final metrics = snapshot.data ?? {'motorists': 0, 'drivers': 0, 'shops': 0, 'openTickets': 0};

                return Column(
                  children: [
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: axisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: aspectRatio,
                      children: [
                        _MetricGlassCard(title: 'Total Motorists', count: metrics['motorists'].toString(), icon: Icons.people, color: Colors.blue),
                        _MetricGlassCard(title: 'Active Drivers', count: metrics['drivers'].toString(), icon: Icons.local_shipping, color: Colors.green),
                        _MetricGlassCard(title: 'Repair Shops', count: metrics['shops'].toString(), icon: Icons.store, color: Colors.purple),
                        _MetricGlassCard(title: 'Open Tickets', count: metrics['openTickets'].toString(), icon: Icons.support_agent, color: Colors.redAccent),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Most frequent service requested and location
                    GlassCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFFF8C00).withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.star, color: Color(0xFFFF8C00), size: 32),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Most Frequent Service Request', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text(metrics['topService'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Hotspot Location', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text(metrics['topLocation'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('User Growth (Last 7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 300,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1)),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) => Text('Day ${value.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: const [FlSpot(1, 2), FlSpot(2, 5), FlSpot(3, 8), FlSpot(4, 12), FlSpot(5, 18), FlSpot(6, 25), FlSpot(7, 35)],
                                  isCurved: true,
                                  color: const Color(0xFFFF8C00),
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(show: true, color: const Color(0xFFFF8C00).withOpacity(0.2)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ));
  }
}

class _MetricGlassCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _MetricGlassCard({required this.title, required this.count, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)],
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Text(count.toString(), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}

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

    return {
      'motorists': motoristsRes.count,
      'drivers': driversRes.count,
      'shops': shopsRes.count,
      'openTickets': ticketsRes.count,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
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
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.8,
                    children: [
                      _MetricGlassCard(title: 'Total Motorists', count: metrics['motorists']!, icon: Icons.people, color: Colors.blue),
                      _MetricGlassCard(title: 'Active Drivers', count: metrics['drivers']!, icon: Icons.local_shipping, color: Colors.green),
                      _MetricGlassCard(title: 'Repair Shops', count: metrics['shops']!, icon: Icons.store, color: Colors.purple),
                      _MetricGlassCard(title: 'Open Tickets', count: metrics['openTickets']!, icon: Icons.support_agent, color: Colors.redAccent),
                    ],
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
    );
  }
}

class _MetricGlassCard extends StatelessWidget {
  final String title;
  final int count;
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

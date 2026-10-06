import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  Future<Map<String, int>> _fetchMetrics() async {
    final client = Supabase.instance.client;
    
    // Fetch counts using count=exact
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<Map<String, int>>(
              future: _fetchMetrics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading metrics: ${snapshot.error}'));
                }

                final metrics = snapshot.data ?? {'motorists': 0, 'drivers': 0, 'shops': 0, 'openTickets': 0};

                return GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _MetricCard(title: 'Total Motorists', count: metrics['motorists']!, icon: Icons.people, color: Colors.blue),
                    _MetricCard(title: 'Active Drivers', count: metrics['drivers']!, icon: Icons.local_shipping, color: Colors.green),
                    _MetricCard(title: 'Repair Shops', count: metrics['shops']!, icon: Icons.store, color: Colors.purple),
                    _MetricCard(title: 'Open Tickets', count: metrics['openTickets']!, icon: Icons.support_agent, color: Colors.red),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

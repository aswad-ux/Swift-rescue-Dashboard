import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopsPage extends StatelessWidget {
  const ShopsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('All Repair Shops', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder(
              future: Supabase.instance.client.from('profiles').select().eq('role', 'repair_shop'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final shops = snapshot.data as List<dynamic>? ?? [];
                
                return Card(
                  color: const Color(0xFF1E1E1E),
                  child: ListView.separated(
                    itemCount: shops.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.store, color: Colors.white)),
                        title: Text(shop['full_name'] ?? 'Unknown Shop'),
                        subtitle: Text(shop['company_name'] ?? shop['phone'] ?? 'No details'),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

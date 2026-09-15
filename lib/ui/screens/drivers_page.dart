import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriversPage extends StatelessWidget {
  const DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('All Drivers (Providers)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder(
              future: Supabase.instance.client.from('profiles').select().eq('role', 'provider'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final drivers = snapshot.data as List<dynamic>? ?? [];
                
                return Card(
                  color: const Color(0xFF1E1E1E),
                  child: ListView.separated(
                    itemCount: drivers.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.local_shipping, color: Colors.white)),
                        title: Text(driver['full_name'] ?? 'Unknown Driver'),
                        subtitle: Text(driver['phone'] ?? 'No phone'),
                        trailing: Text(driver['vehicle_plate'] ?? ''),
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

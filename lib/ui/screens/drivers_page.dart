import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriversPage extends StatelessWidget {
  const DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Providers (Drivers)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
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
                  elevation: 4,
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFF2C2C2C)),
                        columns: const [
                          DataColumn(label: Text('Driver Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Vehicle Plate', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Joined Date', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: drivers.map((driver) {
                          return DataRow(
                            cells: [
                              DataCell(Row(
                                children: [
                                  const CircleAvatar(radius: 16, backgroundColor: Colors.green, child: Icon(Icons.local_shipping, size: 16, color: Colors.white)),
                                  const SizedBox(width: 12),
                                  Text(driver['full_name'] ?? 'Unknown Driver'),
                                ],
                              )),
                              DataCell(Text(driver['phone'] ?? 'No phone')),
                              DataCell(Text(driver['vehicle_plate'] ?? 'N/A')),
                              DataCell(Text(driver['created_at']?.toString().split('T').first ?? '')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
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

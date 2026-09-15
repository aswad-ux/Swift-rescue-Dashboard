import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  Future<List<dynamic>> _fetchTickets() async {
    final response = await Supabase.instance.client
        .from('support_tickets')
        .select('*, profiles!support_tickets_user_id_fkey(full_name, email)')
        .order('created_at', ascending: false);
    return response as List<dynamic>;
  }

  Future<void> _updateTicketStatus(String id, String status) async {
    await Supabase.instance.client
        .from('support_tickets')
        .update({'status': status})
        .eq('id', id);
    setState(() {}); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Support CRM', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder(
              future: _fetchTickets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final tickets = snapshot.data as List<dynamic>? ?? [];
                
                return Card(
                  color: const Color(0xFF1E1E1E),
                  child: ListView.separated(
                    itemCount: tickets.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      final user = ticket['profiles'] ?? {};
                      final status = ticket['status'] ?? 'Open';
                      
                      Color statusColor = Colors.grey;
                      if (status == 'Open') statusColor = Colors.red;
                      if (status == 'Resolved') statusColor = Colors.green;
                      if (status == 'In Progress') statusColor = Colors.orange;
                      
                      return ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.2),
                          child: Icon(Icons.confirmation_number, color: statusColor),
                        ),
                        title: Text(ticket['subject'] ?? 'No Subject', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('From: ${user['full_name'] ?? 'Unknown'} • Status: $status'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Message:', style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text(ticket['message'] ?? ''),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    if (status != 'Resolved')
                                      ElevatedButton(
                                        onPressed: () => _updateTicketStatus(ticket['id'], 'Resolved'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                        child: const Text('Mark Resolved'),
                                      ),
                                    const SizedBox(width: 8),
                                    if (status == 'Open')
                                      OutlinedButton(
                                        onPressed: () => _updateTicketStatus(ticket['id'], 'In Progress'),
                                        child: const Text('Mark In Progress'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
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

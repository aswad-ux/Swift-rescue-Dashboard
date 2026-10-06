import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_rescue_admin/ui/widgets/glass_card.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  Map<String, dynamic>? _selectedTicket;
  List<dynamic> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('support_tickets')
          .select('*, profiles!support_tickets_user_id_fkey(full_name)')
          .order('created_at', ascending: false);
      setState(() {
        _tickets = response as List<dynamic>;
        _isLoading = false;
        // Optionally auto-select first ticket
        if (_tickets.isNotEmpty && _selectedTicket == null) {
          _selectedTicket = _tickets.first;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTicketStatus(String id, String status) async {
    await Supabase.instance.client
        .from('support_tickets')
        .update({'status': status})
        .eq('id', id);
    _fetchTickets();
    if (_selectedTicket != null && _selectedTicket!['id'] == id) {
      setState(() {
        _selectedTicket!['status'] = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Support CRM', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 800;
                      
                      final listPane = Expanded(
                        flex: 1,
                        child: GlassCard(
                          padding: 0,
                          child: ListView.separated(
                            itemCount: _tickets.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black26),
                            itemBuilder: (context, index) {
                              final ticket = _tickets[index];
                              final user = ticket['profiles'] ?? {};
                              final status = ticket['status'] ?? 'Open';
                              final isSelected = _selectedTicket?['id'] == ticket['id'];

                              Color statusColor = Colors.grey;
                              if (status == 'Open') statusColor = Colors.red;
                              if (status == 'Resolved') statusColor = Colors.green;
                              if (status == 'In Progress') statusColor = Colors.orange;

                              return ListTile(
                                selected: isSelected,
                                selectedTileColor: const Color(0xFFFF8C00).withOpacity(0.1),
                                leading: CircleAvatar(
                                  backgroundColor: statusColor.withOpacity(0.2),
                                  child: Icon(Icons.confirmation_number, color: statusColor, size: 20),
                                ),
                                title: Text(ticket['subject'] ?? 'No Subject', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(user['full_name'] ?? 'Unknown', maxLines: 1),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedTicket = ticket;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      );

                      final detailPane = Expanded(
                        flex: isMobile ? 1 : 2,
                        child: _selectedTicket == null
                            ? const Center(child: Text('Select a ticket to view details', style: TextStyle(color: Colors.grey)))
                            : GlassCard(
                                padding: 32.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              if (isMobile) ...[
                                                IconButton(
                                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                                  onPressed: () => setState(() => _selectedTicket = null),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Text('Ticket #${_selectedTicket!['id'].toString().substring(0, 8)}', style: const TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                          Text(_selectedTicket!['created_at'].toString().split('T').first, style: const TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(_selectedTicket!['subject'] ?? 'No Subject', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 24),
                                      const Divider(),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const CircleAvatar(radius: 24, backgroundColor: Colors.blueGrey, child: Icon(Icons.person, size: 28)),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(_selectedTicket!['profiles']?['full_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              Text(_selectedTicket!['profiles']?['email'] ?? 'No email', style: const TextStyle(color: Colors.grey)),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      const Text('Message', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                        child: Text(_selectedTicket!['message'] ?? 'No message provided', style: const TextStyle(fontSize: 16, height: 1.5)),
                                      ),
                                      const Spacer(),
                                      const Divider(),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          if (_selectedTicket!['status'] == 'Open')
                                            OutlinedButton.icon(
                                              onPressed: () => _updateTicketStatus(_selectedTicket!['id'], 'In Progress'),
                                              icon: const Icon(Icons.sync),
                                              label: const Text('Mark In Progress'),
                                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                                            ),
                                          const SizedBox(width: 16),
                                          if (_selectedTicket!['status'] != 'Resolved')
                                            ElevatedButton.icon(
                                              onPressed: () => _updateTicketStatus(_selectedTicket!['id'], 'Resolved'),
                                              icon: const Icon(Icons.check),
                                              label: const Text('Resolve Ticket'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                              ),
                                            ),
                                        ],
                                      )
                                    ],
                                  ),
                              ),
                      );
                      
                      if (isMobile) {
                        return Row(
                          children: [
                            if (_selectedTicket == null) listPane else detailPane,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          listPane,
                          const SizedBox(width: 24),
                          detailPane,
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

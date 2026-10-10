import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_rescue_admin/ui/widgets/glass_card.dart';

class UserDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  
  const UserDetailsDialog({super.key, required this.user});

  @override
  State<UserDetailsDialog> createState() => _UserDetailsDialogState();
}

class _UserDetailsDialogState extends State<UserDetailsDialog> {
  bool _isLoading = true;
  List<dynamic> _vehicles = [];
  List<dynamic> _jobs = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final client = Supabase.instance.client;
    final userId = widget.user['id'];
    
    try {
      final vehiclesRes = await client.from('vehicles').select('*').eq('motorist_id', userId);
      final jobsRes = await client.from('jobs').select('*').eq('motorist_id', userId).order('created_at', ascending: false).limit(5);
      
      if (mounted) {
        setState(() {
          _vehicles = vehiclesRes;
          _jobs = jobsRes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 24, backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.user['full_name'] ?? 'Unknown User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(widget.user['phone'] ?? 'No Phone', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('CRM Details'),
                          const SizedBox(height: 16),
                          GlassCard(
                            padding: 16,
                            child: Column(
                              children: [
                                _buildDetailRow('User ID', widget.user['id'] ?? 'N/A'),
                                const Divider(color: Colors.white10),
                                _buildDetailRow('Joined Date', widget.user['created_at']?.split('T').first ?? 'N/A'),
                                const Divider(color: Colors.white10),
                                _buildDetailRow('Emergency Contacts', widget.user['emergency_contacts']?.toString() ?? 'None configured'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Registered Vehicles'),
                          const SizedBox(height: 16),
                          if (_vehicles.isEmpty)
                            const Text('No vehicles registered.', style: TextStyle(color: Colors.grey))
                          else
                            ..._vehicles.map((v) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassCard(
                                padding: 16,
                                child: Row(
                                  children: [
                                    const Icon(Icons.directions_car, color: Color(0xFFFF8C00)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('\${v['make'] ?? ''} \${v['model'] ?? ''} \${v['year'] ?? ''}'.trim(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                          Text('Color: \${v['color'] ?? 'Unknown'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                                      child: Text(v['license_plate'] ?? 'No Plate', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            )).toList(),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Recent Service Requests'),
                          const SizedBox(height: 16),
                          if (_jobs.isEmpty)
                            const Text('No recent service requests.', style: TextStyle(color: Colors.grey))
                          else
                            ..._jobs.map((j) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.build, color: Colors.grey, size: 20)),
                              title: Text(j['service_type'] ?? 'Unknown Service', style: const TextStyle(color: Colors.white)),
                              subtitle: Text(j['created_at']?.split('T').first ?? '', style: const TextStyle(color: Colors.grey)),
                              trailing: Text(j['status'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8C00))),
                            )).toList(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF8C00)));
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

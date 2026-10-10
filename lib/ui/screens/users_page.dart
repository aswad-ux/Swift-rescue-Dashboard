import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_rescue_admin/ui/widgets/glass_card.dart';
import 'package:swift_rescue_admin/ui/widgets/add_user_dialog.dart';
import 'package:swift_rescue_admin/ui/widgets/user_details_dialog.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String _searchQuery = '';
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response = await Supabase.instance.client.from('profiles').select().eq('role', 'motorist');
    setState(() {
      _users = response as List<dynamic>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((user) {
      final name = (user['full_name'] ?? '').toString().toLowerCase();
      final phone = (user['phone'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || phone.contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Motorists', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by name or phone...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (context) => const AddUserDialog(role: 'motorist'),
                        );
                        if (result == true) _fetchUsers();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Motorist'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (filteredUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No users found.', style: TextStyle(color: Colors.grey, fontSize: 16))),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 128),
                        child: PaginatedDataTable(
                          showCheckboxColumn: false,
                          arrowHeadColor: Colors.white,
                          headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
                          columns: const [
                            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text('Joined Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          ],
                          source: _UserData(filteredUsers, context),
                          rowsPerPage: 8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserData extends DataTableSource {
  final List<dynamic> data;
  final BuildContext context;
  _UserData(this.data, this.context);

  @override
  DataRow getRow(int index) {
    final user = data[index];
    return DataRow(
      onSelectChanged: (_) {
        showDialog(
          context: context,
          builder: (context) => UserDetailsDialog(user: user),
        );
      },
      cells: [
        DataCell(Row(
          children: [
            const CircleAvatar(radius: 14, backgroundColor: Colors.blue, child: Icon(Icons.person, size: 14, color: Colors.white)),
            const SizedBox(width: 12),
            Text(user['full_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
          ],
        )),
        DataCell(Text(user['phone'] ?? 'No phone', style: const TextStyle(color: Colors.grey))),
        DataCell(Text(user['created_at']?.toString().split('T').first ?? '', style: const TextStyle(color: Colors.grey))),
        DataCell(
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text('View Details')),
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
            onSelected: (value) {
              if (value == 'view') {
                showDialog(
                  context: context,
                  builder: (context) => UserDetailsDialog(user: user),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}

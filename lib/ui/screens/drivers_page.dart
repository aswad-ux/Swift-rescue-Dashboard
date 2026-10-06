import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_rescue_admin/ui/widgets/glass_card.dart';
import 'package:swift_rescue_admin/ui/widgets/add_user_dialog.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  String _searchQuery = '';
  List<dynamic> _drivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    final response = await Supabase.instance.client.from('profiles').select().eq('role', 'provider');
    setState(() {
      _drivers = response as List<dynamic>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredDrivers = _drivers.where((driver) {
      final name = (driver['full_name'] ?? '').toString().toLowerCase();
      final phone = (driver['phone'] ?? '').toString().toLowerCase();
      final plate = (driver['vehicle_plate'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || 
             phone.contains(_searchQuery.toLowerCase()) ||
             plate.contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Providers', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
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
                          hintText: 'Search by name, phone, or plate...',
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
                          builder: (context) => const AddUserDialog(role: 'provider'),
                        );
                        if (result == true) _fetchDrivers();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Driver'),
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
                else if (filteredDrivers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No providers found.', style: TextStyle(color: Colors.grey, fontSize: 16))),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 128),
                        child: PaginatedDataTable(
                          arrowHeadColor: Colors.white,
                          headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
                          columns: const [
                            DataColumn(label: Text('Driver Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text('Plate', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text('Joined Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          ],
                          source: _DriverData(filteredDrivers, context),
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

class _DriverData extends DataTableSource {
  final List<dynamic> data;
  final BuildContext context;
  _DriverData(this.data, this.context);

  @override
  DataRow getRow(int index) {
    final driver = data[index];
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            const CircleAvatar(radius: 14, backgroundColor: Colors.green, child: Icon(Icons.local_shipping, size: 14, color: Colors.white)),
            const SizedBox(width: 12),
            Text(driver['full_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
          ],
        )),
        DataCell(Text(driver['phone'] ?? 'No phone', style: const TextStyle(color: Colors.grey))),
        DataCell(Text(driver['vehicle_plate'] ?? 'N/A', style: const TextStyle(color: Colors.grey))),
        DataCell(Text(driver['created_at']?.toString().split('T').first ?? '', style: const TextStyle(color: Colors.grey))),
        DataCell(
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
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

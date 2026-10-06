import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_rescue_admin/ui/widgets/glass_card.dart';
import 'package:swift_rescue_admin/ui/widgets/add_user_dialog.dart';

class ShopsPage extends StatefulWidget {
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  String _searchQuery = '';
  List<dynamic> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    final response = await Supabase.instance.client.from('profiles').select().eq('role', 'repair_shop');
    setState(() {
      _shops = response as List<dynamic>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredShops = _shops.where((shop) {
      final name = (shop['full_name'] ?? '').toString().toLowerCase();
      final company = (shop['company_name'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || company.contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Repair Shops', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by name or company...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (context) => const AddUserDialog(role: 'repair_shop'),
                        );
                        if (result == true) _fetchShops();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Shop'),
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
                else if (filteredShops.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No shops found.', style: TextStyle(color: Colors.grey, fontSize: 16))),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: PaginatedDataTable(
                      arrowHeadColor: Colors.white,
                      headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
                      columns: const [
                        DataColumn(label: Text('Shop Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Joined Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                      ],
                      source: _ShopData(filteredShops, context),
                      rowsPerPage: 8,
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

class _ShopData extends DataTableSource {
  final List<dynamic> data;
  final BuildContext context;
  _ShopData(this.data, this.context);

  @override
  DataRow getRow(int index) {
    final shop = data[index];
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            const CircleAvatar(radius: 14, backgroundColor: Colors.purple, child: Icon(Icons.store, size: 14, color: Colors.white)),
            const SizedBox(width: 12),
            Text(shop['full_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
          ],
        )),
        DataCell(Text(shop['company_name'] ?? 'N/A', style: const TextStyle(color: Colors.grey))),
        DataCell(Text(shop['phone'] ?? 'No phone', style: const TextStyle(color: Colors.grey))),
        DataCell(Text(shop['created_at']?.toString().split('T').first ?? '', style: const TextStyle(color: Colors.grey))),
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

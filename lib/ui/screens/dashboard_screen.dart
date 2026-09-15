import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_rescue_admin/ui/screens/users_page.dart';
import 'package:swift_rescue_admin/ui/screens/shops_page.dart';
import 'package:swift_rescue_admin/ui/screens/drivers_page.dart';
import 'package:swift_rescue_admin/ui/screens/support_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SupportPage(),
    const UsersPage(),
    const ShopsPage(),
    const DriversPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swift Rescue Admin', style: TextStyle(color: Color(0xFFFF8C00), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          )
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFF1E1E1E),
            indicatorColor: const Color(0xFFFF8C00).withOpacity(0.2),
            selectedIconTheme: const IconThemeData(color: Color(0xFFFF8C00)),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFFFF8C00), fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.support_agent),
                label: Text('Support CRM'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.store),
                label: Text('Shops'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_shipping),
                label: Text('Drivers'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

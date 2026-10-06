import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_rescue_admin/ui/screens/overview_page.dart';
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
  bool _isExpanded = true;

  final List<Widget> _pages = [
    const OverviewPage(),
    const SupportPage(),
    const UsersPage(),
    const ShopsPage(),
    const DriversPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      appBar: AppBar(
        leading: isMobile ? null : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
        ),
        title: const Text('Swift Rescue Admin', style: TextStyle(color: Color(0xFFFF8C00), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121212), Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            if (!isMobile) ...[
              NavigationRail(
                extended: _isExpanded,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                backgroundColor: Colors.transparent,
                indicatorColor: const Color(0xFFFF8C00).withOpacity(0.2),
                selectedIconTheme: const IconThemeData(color: Color(0xFFFF8C00)),
                selectedLabelTextStyle: const TextStyle(color: Color(0xFFFF8C00), fontWeight: FontWeight.bold),
                unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Overview')),
                  NavigationRailDestination(icon: Icon(Icons.support_agent), label: Text('Support CRM')),
                  NavigationRailDestination(icon: Icon(Icons.people), label: Text('Motorists')),
                  NavigationRailDestination(icon: Icon(Icons.store), label: Text('Repair Shops')),
                  NavigationRailDestination(icon: Icon(Icons.local_shipping), label: Text('Providers')),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
            ],
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),
      bottomNavigationBar: isMobile ? BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFFFF8C00),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1E1E1E),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Motorists'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Drivers'),
        ],
      ) : null,
    );
  }
}

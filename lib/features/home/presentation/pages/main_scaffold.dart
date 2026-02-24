import 'package:flutter/material.dart';
import '../../../../app/di/app_dependencies.dart';
import '../../client_cards/presentation/pages/home_cards_page.dart';
import '../../profile/presentation/pages/profile_page.dart';
import '../../rewards/presentation/pages/rewards_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeCardsPage(dependencies: widget.dependencies),
      const RewardsPage(),
      ProfilePage(dependencies: widget.dependencies),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Tarjetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.redeem),
            label: 'Premios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'livre_list_screen.dart';
import 'ecrivain_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const LivreListScreen(),
    const EcrivainListScreen(),
  ];

  final List<String> _titles = [
    'Livres',
    'Écrivains',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_library,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gestion Bibliothèque',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez vos livres et écrivains',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Menu Livres
            ListTile(
              leading: Icon(
                Icons.book,
                color: _selectedIndex == 0
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(
                'Livres',
                style: TextStyle(
                  fontWeight:
                      _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                  color: _selectedIndex == 0
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              selected: _selectedIndex == 0,
              selectedTileColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            // Menu Écrivains
            ListTile(
              leading: Icon(
                Icons.people,
                color: _selectedIndex == 1
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(
                'Écrivains',
                style: TextStyle(
                  fontWeight:
                      _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                  color: _selectedIndex == 1
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              selected: _selectedIndex == 1,
              selectedTileColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            // À propos
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('À propos'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Gestion Bibliothèque',
                  applicationVersion: '1.0.0',
                  applicationIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_library,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  children: [
                    const Text(
                      'Application de gestion de bibliothèque permettant de gérer les livres et les écrivains.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}

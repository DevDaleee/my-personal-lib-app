import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Abas da barra inferior, com a rota de cada uma.
enum AppTab {
  library('/home'),
  stats('/stats');

  const AppTab(this.path);

  final String path;
}

/// Barra inferior: Biblioteca e Estatísticas. Troca de aba com `go` (sem empilhar telas).
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({super.key, required this.current});

  final AppTab current;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current.index,
      onDestinationSelected: (index) {
        final tab = AppTab.values[index];
        if (tab != current) context.go(tab.path);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Biblioteca'),
        NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Estatísticas'),
      ],
    );
  }
}

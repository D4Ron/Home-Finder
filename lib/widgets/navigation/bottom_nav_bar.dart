import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/message_provider.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/favourites/favourites_screen.dart';
import '../../screens/messages/conversations_screen.dart';
import '../../screens/profile/profile_screen.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  static const _screens = [
    HomeScreen(),
    FavouritesScreen(),
    ConversationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          if (i == currentIndex) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => _screens[i],
              transitionDuration: Duration.zero,
            ),
          );
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoris'),
          BottomNavigationBarItem(
            label: 'Messages',
            icon: Consumer<MessageProvider>(
              builder: (_, mp, __) => Badge(
                isLabelVisible: mp.unreadCount > 0,
                label: Text('${mp.unreadCount}'),
                child: const Icon(Icons.chat_bubble_outline),
              ),
            ),
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
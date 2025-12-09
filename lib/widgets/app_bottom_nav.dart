import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../screens/home_screen.dart';
import '../screens/favoris_screen.dart';
import '../screens/profile_screen.dart';


class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: AppColors.textGray,
        currentIndex: currentIndex,
        onTap: (index) {
          // Don't navigate if already on this screen
          if (index == currentIndex) return;

          if (index == 0) {
            // Navigate to Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            // Navigate to Annonces
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const AnnoncesScreen()),
            // );
            print('Annonces - Coming soon');
          } else if (index == 2) {
            // Navigate to Favoris
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FavorisScreen()),
            );
          } else if (index == 3) {
            // Navigate to Profil
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Annonces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
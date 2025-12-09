
import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}

// Classe de données pour définir les éléments des listes
class ProfileItemData {
  final IconData icon;
  final String title;
  final int? badgeCount; // Compteur optionnel pour la section Activité
  final String? routeName; // Pour une navigation future

  const ProfileItemData(this.icon, this.title, {this.badgeCount, this.routeName});
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- DONNÉES STATIQUES ---
  final List<ProfileItemData> activityItems = const [
    ProfileItemData(Icons.bookmark_border, 'Biens sauvegardés', badgeCount: 10),
    ProfileItemData(Icons.chat_bubble_outline, 'Conversations', badgeCount: 5),
    ProfileItemData(Icons.calendar_today_outlined, 'Visites planifiées', badgeCount: 20),
  ];

  final List<ProfileItemData> preferenceItems = const [
    ProfileItemData(Icons.notifications_none_outlined, 'Notifications et alertes'),
    ProfileItemData(Icons.location_on_outlined, 'Zones et Budget'),
    ProfileItemData(Icons.security_outlined, 'Sécurité du compte'),
  ];

  final List<String> shortcutItems = const [
    'Devenir Agent',
    'Inviter des amis',
    'Centre d\'aide',
    'A propos',
  ];

  // --- WIDGETS D'AIDE ---

  // Construit un élément de la liste Activité avec un badge
  Widget _buildActivityItem(ProfileItemData item) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.black, size: 24),
      title: Text(item.title, style: const TextStyle(fontSize: 16)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          item.badgeCount.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {}, // Action future
    );
  }

  // Construit un élément de la liste Préférences avec une flèche
  Widget _buildPreferenceItem(ProfileItemData item) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.black, size: 24),
      title: Text(item.title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {}, // Action future
    );
  }

  // --- WIDGET PRINCIPAL (BUILD) ---
  @override
  Widget build(BuildContext context) {
    const Color backgroundGlobal = Colors.white;
    final Color? backgroundHeader = Colors.grey[100];

    return Scaffold(
      backgroundColor: backgroundGlobal,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ----------------------------------------------------
            // 1. SECTION HEADER (Titre 'Profil' et Icône Paramètres)
            // ----------------------------------------------------
            Container(
              color: backgroundHeader,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profil',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gérez votre compte et vos préférences',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.settings_outlined, color: Colors.black, size: 24),
                    ],
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // 2. SECTION INFO UTILISATEUR (Image, Nom, Email, Bouton Modifier)
            // ----------------------------------------------------
            Container(
              width: double.infinity,
              color: backgroundHeader,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // L'IMAGE DE PROFIL
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.transparent, // Fond transparent si l'image a de la transparence
                    backgroundImage: AssetImage('assets/images/user.jpg'), // TON IMAGE ICI
                  ),
                  const SizedBox(width: 16),

                  // NOM, EMAIL et MEMBRE DEPUIS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('ABALO L. ROI',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                        SizedBox(height: 2),
                        Text('abaloroi@gmail.com',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('Membre depuis 2020',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),

                  // BOUTON MODIFIER
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Modifier', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),

            Container(height: 10, color: backgroundGlobal),

            // ----------------------------------------------------
            // 3. SECTION ACTIVITÉ
            // ----------------------------------------------------
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Activité',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            ...activityItems.map(_buildActivityItem), // .toList() n'est plus obligatoire ici en Dart moderne

            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 10),

            // ----------------------------------------------------
            // 4. SECTION PRÉFÉRENCES
            // ----------------------------------------------------
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Préférences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            ...preferenceItems.map(_buildPreferenceItem),

            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 10),

            // ----------------------------------------------------
            // 5. SECTION RACCOURCIS
            // ----------------------------------------------------
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Raccourcis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calcul pour avoir 2 boutons par ligne avec un espacement de 10
                  final double buttonWidth = (constraints.maxWidth - 10) / 2;

                  return Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: shortcutItems.map((text) {
                      return SizedBox(
                        width: buttonWidth,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(text, style: const TextStyle(fontSize: 14)),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            // ----------------------------------------------------
            // 6. BOUTON 'Se déconnecter'
            // ----------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Se déconnecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // ----------------------------------------------------
      // 7. BOTTOM NAVIGATION BAR
      // ----------------------------------------------------
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

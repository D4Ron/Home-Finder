import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/alert_model.dart';
import '../../providers/favourite_provider.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/common/property_card.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../property/property_detail_screen.dart';
import '../alerts/alerts_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouriteProvider>().load();
      context.read<AlertProvider>().loadAlerts();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.favourites,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(AppStrings.myFavourites,
                style: TextStyle(
                    color: AppColors.textGrey, fontSize: AppSizes.fontXs)),
          ],
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.favorite_outline), text: 'Favoris'),
            Tab(icon: Icon(Icons.notifications_outlined), text: 'Alertes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _FavList(),
          _AlertsTab(),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _FavList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FavouriteProvider>(builder: (_, favs, __) {
      if (favs.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (favs.error != null && favs.favourites.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(favs.error!,
                  style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: AppSizes.md),
              ElevatedButton(
                onPressed: favs.load,
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        );
      }
      if (favs.favourites.isEmpty) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 64, color: AppColors.textLight),
              SizedBox(height: AppSizes.md),
              Text('Aucun favori pour l\'instant',
                  style: TextStyle(color: AppColors.textGrey)),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: favs.load,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: favs.favourites.length,
          itemBuilder: (_, i) {
            final p = favs.favourites[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: PropertyCard(
                property: p,
                showBadge: i == 0,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PropertyDetailScreen(propertyId: p.id),
                  ),
                ),
                onFavouriteTap: () => favs.toggle(p),
              ),
            );
          },
        ),
      );
    });
  }
}

class _AlertsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(builder: (_, ap, __) {
      if (ap.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (ap.alerts.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_none,
                  size: 64, color: AppColors.textLight),
              const SizedBox(height: AppSizes.md),
              const Text('Aucune alerte créée',
                  style: TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: AppSizes.md),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Créer une alerte'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: ap.loadAlerts,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: ap.alerts.length,
          itemBuilder: (_, i) => _InlineAlertCard(alert: ap.alerts[i]),
        ),
      );
    });
  }
}

class _InlineAlertCard extends StatelessWidget {
  final AlertModel alert;
  const _InlineAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm),
        leading: Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            alert.active
                ? Icons.notifications_active
                : Icons.notifications_off_outlined,
            color:
            alert.active ? AppColors.primary : AppColors.textGrey,
          ),
        ),
        title: Text(alert.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          [
            if (alert.city != null) alert.city!,
            if (alert.propertyType != null) alert.propertyType!,
            alert.frequencyLabel,
          ].join(' · '),
          style: const TextStyle(
              color: AppColors.textGrey, fontSize: AppSizes.fontSm),
        ),
        trailing: Switch(
          value: alert.active,
          onChanged: (_) =>
              context.read<AlertProvider>().toggleAlert(alert.id),
          activeColor: AppColors.primary,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/favourite_provider.dart';
import '../../widgets/common/property_card.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../property/property_detail_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  bool _alertsEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouriteProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            _AlertBanner(
              enabled: _alertsEnabled,
              onToggle: (v) => setState(() => _alertsEnabled = v),
            ),
            Expanded(child: _FavList()),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.favourites,
                  style: TextStyle(
                      fontSize: AppSizes.fontXl, fontWeight: FontWeight.bold)),
              Text(AppStrings.myFavourites,
                  style: TextStyle(
                      color: AppColors.textGrey, fontSize: AppSizes.fontSm)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final bool           enabled;
  final ValueChanged<bool> onToggle;
  const _AlertBanner({required this.enabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.textDark,
            child: Icon(Icons.notifications, color: AppColors.textWhite),
          ),
          const SizedBox(width: AppSizes.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.alertsSubtitle,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Nouvelles annonces correspondantes',
                    style: TextStyle(
                        color: AppColors.textGrey, fontSize: AppSizes.fontSm)),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
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
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
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
                  builder: (_) => PropertyDetailScreen(propertyId: p.id),
                ),
              ),
              onFavouriteTap: () => favs.toggle(p),
            ),
          );
        },
      );
    });
  }
}
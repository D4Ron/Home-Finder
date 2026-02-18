import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/favourite_provider.dart';
import '../../widgets/common/property_card.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../property/property_detail_screen.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/category_chips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollCtrl  = ScrollController();
  final _searchCtrl  = TextEditingController();
  String? _activeType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().load(refresh: true);
      context.read<FavouriteProvider>().load();
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent * 0.85) {
      context.read<PropertyProvider>().loadMore();
    }
  }

  void _applyType(String? type) {
    setState(() => _activeType = type);
    context.read<PropertyProvider>().load(type: type, refresh: true);
  }

  void _applySearch() {
    context.read<PropertyProvider>().load(
      city: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      type: _activeType,
      refresh: true,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(user: user),
            _SearchBar(ctrl: _searchCtrl, onSearch: _applySearch),
            const SizedBox(height: AppSizes.md),
            CategoryChips(
              active: _activeType,
              onSelect: _applyType,
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(child: _PropertyList(scrollCtrl: _scrollCtrl)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

// ── Sub-widgets (private, only used in HomeScreen) ────────────────────────────

class _Header extends StatelessWidget {
  final dynamic user;
  const _Header({this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.findHome,
                    style: const TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w500)),
                Text(AppStrings.idealPlace,
                    style: const TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
              ],
            ),
          ),
          CircleAvatar(
            radius: AppSizes.avatarSm / 2,
            backgroundColor: AppColors.primary,
            backgroundImage: user?.profileImageUrl != null
                ? NetworkImage(user!.profileImageUrl!)
                : const AssetImage('assets/images/user.jpg') as ImageProvider,
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSearch;
  const _SearchBar({required this.ctrl, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: AppStrings.search,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(vertical: AppSizes.sm),
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          // Filter button — opens bottom sheet
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusXl)),
              ),
              builder: (_) => FilterBottomSheet(
                onApply: (min, max, beds) =>
                    context.read<PropertyProvider>().load(
                      minPrice: min,
                      maxPrice: max,
                      minBeds: beds,
                      refresh: true,
                    ),
              ),
            ),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child:
              const Icon(Icons.tune, color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyList extends StatelessWidget {
  final ScrollController scrollCtrl;
  const _PropertyList({required this.scrollCtrl});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PropertyProvider, FavouriteProvider>(
      builder: (context, props, favs, _) {
        if (props.loading && props.properties.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (props.error != null && props.properties.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(props.error!, style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: AppSizes.sm),
                TextButton(
                  onPressed: () => props.load(refresh: true),
                  child: const Text(AppStrings.retry),
                ),
              ],
            ),
          );
        }
        if (props.properties.isEmpty) {
          return const Center(child: Text(AppStrings.noData));
        }
        return ListView.builder(
          controller: scrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          itemCount: props.properties.length + (props.loadingMore ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == props.properties.length) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final p = props.properties[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: PropertyCard(
                property: p,
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
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../providers/favourite_provider.dart';
import '../messages/chat_screen.dart';
import 'widgets/image_carousel.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadDetail(widget.propertyId);
    });
  }

  @override
  void dispose() {
    context.read<PropertyProvider>().clearDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(builder: (_, props, __) {
      if (props.loading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (props.detail == null) {
        return const Scaffold(
            body: Center(child: Text(AppStrings.errorGeneric)));
      }
      return _Built(
        property: props.detail!,
        expanded: _expanded,
        onToggleDesc: () => setState(() => _expanded = !_expanded),
      );
    });
  }
}

class _Built extends StatelessWidget {
  final PropertyModel property;
  final bool          expanded;
  final VoidCallback  onToggleDesc;
  const _Built({required this.property, required this.expanded, required this.onToggleDesc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                ImageCarousel(images: property.imageUrls),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + AppSizes.sm,
                  left: AppSizes.md,
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Favourite button
                Positioned(
                  top: MediaQuery.of(context).padding.top + AppSizes.sm,
                  right: AppSizes.md,
                  child: Consumer<FavouriteProvider>(
                    builder: (_, favs, __) => CircleAvatar(
                      backgroundColor: AppColors.surface,
                      child: IconButton(
                        icon: Icon(
                          property.isFavourited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: property.isFavourited
                              ? AppColors.favourite
                              : AppColors.textGrey,
                        ),
                        onPressed: () => favs.toggle(property),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(property.title,
                            style: const TextStyle(
                                fontSize: AppSizes.fontXl,
                                fontWeight: FontWeight.bold)),
                      ),
                      Text(Formatters.price(property.price),
                          style: const TextStyle(
                              fontSize: AppSizes.fontLg,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  // Location & rating
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.address}, ${property.city}',
                          style: const TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                      const Icon(Icons.star, size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(property.rating.toStringAsFixed(1),
                          style: const TextStyle(color: AppColors.textGrey)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  // Specs row
                  _SpecsRow(property: property),
                  const SizedBox(height: AppSizes.lg),
                  // Description
                  const Text(AppStrings.description,
                      style: TextStyle(
                          fontSize: AppSizes.fontLg,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.sm),
                  _Description(text: property.description, expanded: expanded),
                  TextButton(
                    onPressed: onToggleDesc,
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: AppColors.primary),
                    child: Text(expanded
                        ? AppStrings.readLess
                        : AppStrings.readMore),
                  ),
                  const SizedBox(height: AppSizes.md),
                  // Owner card
                  _OwnerCard(property: property),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomActions(property: property),
    );
  }
}

class _SpecsRow extends StatelessWidget {
  final PropertyModel property;
  const _SpecsRow({required this.property});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (property.bedrooms != null)
          _spec(Icons.bed, '${property.bedrooms} Chambres'),
        if (property.bathrooms != null)
          _spec(Icons.bathtub_outlined, '${property.bathrooms} SDB'),
        if (property.area != null)
          _spec(Icons.square_foot, '${property.area}m²'),
        if (property.parkingSpaces != null && property.parkingSpaces! > 0)
          _spec(Icons.local_parking, '${property.parkingSpaces} Parking'),
      ],
    );
  }

  Widget _spec(IconData icon, String label) => Padding(
    padding: const EdgeInsets.only(right: AppSizes.md),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, color: AppColors.textWhite, size: 18),
        ),
        const SizedBox(width: AppSizes.xs),
        Text(label, style: const TextStyle(fontSize: AppSizes.fontSm)),
      ],
    ),
  );
}

class _Description extends StatelessWidget {
  final String text;
  final bool   expanded;
  const _Description({required this.text, required this.expanded});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: expanded ? null : 3,
      overflow: expanded ? null : TextOverflow.ellipsis,
      style: const TextStyle(color: AppColors.textGrey, height: 1.5),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  final PropertyModel property;
  const _OwnerCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSizes.avatarSm / 2,
            backgroundImage: property.ownerImageUrl != null
                ? NetworkImage(property.ownerImageUrl!)
                : const AssetImage('assets/images/profile.jpeg') as ImageProvider,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.ownerName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text(AppStrings.owner,
                    style: TextStyle(
                        color: AppColors.textGrey, fontSize: AppSizes.fontSm)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final PropertyModel property;
  const _BottomActions({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.lg),
      color: AppColors.surface,
      child: Row(
        children: [
          // Message owner button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: IconButton(
              icon: const Icon(Icons.email_outlined, color: AppColors.primary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    otherUserId:    property.ownerId,
                    otherUserName:  property.ownerName,
                    propertyId:     property.id,
                    propertyTitle:  property.title,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          // Placeholder — visit booking (integrate with VisitProvider later)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Visite planifiée')),
                );
              },
              child: const Text(AppStrings.bookVisit),
            ),
          ),
        ],
      ),
    );
  }
}
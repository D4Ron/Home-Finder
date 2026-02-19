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
import '../visits/schedule_visit_sheet.dart';
import 'widgets/image_carousel.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _expanded = false;
  late PropertyProvider _propProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadDetail(widget.propertyId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _propProvider = context.read<PropertyProvider>();
  }

  @override
  void dispose() {
    Future.microtask(() => _propProvider.clearDetail());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(builder: (_, props, __) {
      if (props.detailLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (props.detail == null) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: AppSizes.md),
                const Text(AppStrings.errorGeneric),
                const SizedBox(height: AppSizes.md),
                ElevatedButton(
                  onPressed: () =>
                      props.loadDetail(widget.propertyId),
                  child: const Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        );
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
  final bool expanded;
  final VoidCallback onToggleDesc;

  const _Built({
    required this.property,
    required this.expanded,
    required this.onToggleDesc,
  });

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
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Favourite button
                Positioned(
                  top: MediaQuery.of(context).padding.top + AppSizes.sm,
                  right: AppSizes.md,
                  child: Consumer<FavouriteProvider>(
                    builder: (_, favs, __) {
                      final isFav = favs.isFavourited(property.id);
                      return CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? AppColors.favourite
                                : AppColors.textGrey,
                          ),
                          onPressed: () => favs.toggle(property),
                        ),
                      );
                    },
                  ),
                ),
                // Listing type badge
                Positioned(
                  bottom: AppSizes.md,
                  left: AppSizes.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm, vertical: AppSizes.xs),
                    decoration: BoxDecoration(
                      color: property.listingType == 'SALE'
                          ? AppColors.primary
                          : AppColors.success,
                      borderRadius:
                      BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      property.listingType == 'SALE'
                          ? 'À Vendre'
                          : 'À Louer',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.bold),
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
                  // Title & price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: const TextStyle(
                              fontSize: AppSizes.fontXl,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        Formatters.price(property.price),
                        style: const TextStyle(
                            fontSize: AppSizes.fontLg,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
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
                          style: const TextStyle(
                              color: AppColors.textGrey),
                        ),
                      ),
                      const Icon(Icons.star,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(property.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: AppColors.textGrey)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Specs
                  _SpecsRow(property: property),
                  const SizedBox(height: AppSizes.lg),

                  // Amenities
                  if (property.amenities.isNotEmpty) ...[
                    const Text('Équipements',
                        style: TextStyle(
                            fontSize: AppSizes.fontLg,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSizes.sm),
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: property.amenities
                          .map((a) => Chip(
                        label: Text(a,
                            style: const TextStyle(
                                fontSize: AppSizes.fontXs)),
                        backgroundColor:
                        AppColors.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(
                            color: AppColors.primary),
                        padding: EdgeInsets.zero,
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: AppSizes.lg),
                  ],

                  // Description
                  const Text(AppStrings.description,
                      style: TextStyle(
                          fontSize: AppSizes.fontLg,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.sm),
                  AnimatedCrossFade(
                    firstChild: Text(
                      property.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textGrey, height: 1.5),
                    ),
                    secondChild: Text(
                      property.description,
                      style: const TextStyle(
                          color: AppColors.textGrey, height: 1.5),
                    ),
                    crossFadeState: expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
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

                  // Owner
                  _OwnerCard(property: property),
                  const SizedBox(height: AppSizes.sm),

                  // Stats row
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 14, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text('${property.viewCount} vue(s)',
                          style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: AppSizes.fontSm)),
                    ],
                  ),
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
    return Wrap(
      spacing: AppSizes.md,
      runSpacing: AppSizes.sm,
      children: [
        if (property.bedrooms != null && property.bedrooms! > 0)
          _spec(Icons.bed, '${property.bedrooms} Ch.'),
        if (property.bathrooms != null && property.bathrooms! > 0)
          _spec(Icons.bathtub_outlined, '${property.bathrooms} SDB'),
        if (property.area != null)
          _spec(Icons.square_foot, '${property.area}m²'),
        if (property.parkingSpaces != null && property.parkingSpaces! > 0)
          _spec(Icons.local_parking, '${property.parkingSpaces} Parking'),
      ],
    );
  }

  Widget _spec(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md, vertical: AppSizes.sm),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: AppSizes.xs),
        Text(label,
            style: const TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.primary,
                fontWeight: FontWeight.w600)),
      ],
    ),
  );
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
        border: Border.all(color: AppColors.textLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSizes.avatarSm / 2,
            backgroundImage: property.ownerImageUrl != null
                ? NetworkImage(property.ownerImageUrl!)
                : const AssetImage('assets/images/profile.jpeg')
            as ImageProvider,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.ownerName,
                    style:
                    const TextStyle(fontWeight: FontWeight.bold)),
                const Text(AppStrings.owner,
                    style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: AppSizes.fontSm)),
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
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        AppSizes.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Message owner
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: IconButton(
              tooltip: 'Contacter le propriétaire',
              icon: const Icon(Icons.chat_outlined,
                  color: AppColors.primary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    otherUserId:   property.ownerId,
                    otherUserName: property.ownerName,
                    propertyId:    property.id,
                    propertyTitle: property.title,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          // Book visit — now opens the schedule sheet
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text(AppStrings.bookVisit),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusXl)),
                ),
                builder: (_) => ScheduleVisitSheet(
                  propertyId:    property.id,
                  propertyTitle: property.title,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
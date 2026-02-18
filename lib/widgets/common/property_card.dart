import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/property_model.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback  onTap;
  final VoidCallback? onFavouriteTap;
  final bool          showBadge;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.onFavouriteTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Image(property: property, onFavTap: onFavouriteTap, showBadge: showBadge),
            _Info(property: property),
          ],
        ),
      ),
    );
  }
}

class _Image extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onFavTap;
  final bool          showBadge;
  const _Image({required this.property, this.onFavTap, required this.showBadge});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg),
          ),
          child: property.imageUrls.isNotEmpty
              ? Image.network(
            property.imageUrls.first,
            height: AppSizes.propertyCardH,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
              : _placeholder(),
        ),
        if (showBadge)
          Positioned(
            top: AppSizes.sm,
            left: AppSizes.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: const Text('NOUVEAU',
                  style: TextStyle(color: Colors.white,
                      fontSize: AppSizes.fontXs, fontWeight: FontWeight.bold)),
            ),
          ),
        if (onFavTap != null)
          Positioned(
            top: AppSizes.sm,
            right: AppSizes.sm,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surface,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  property.isFavourited ? Icons.favorite : Icons.favorite_border,
                  color: property.isFavourited
                      ? AppColors.favourite
                      : AppColors.textGrey,
                  size: AppSizes.fontLg,
                ),
                onPressed: onFavTap,
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() => Container(
    height: AppSizes.propertyCardH,
    color: AppColors.background,
    child: const Icon(Icons.home, size: 60, color: AppColors.textLight),
  );
}

class _Info extends StatelessWidget {
  final PropertyModel property;
  const _Info({required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(property.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: AppSizes.fontLg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textGrey),
              const SizedBox(width: 2),
              Expanded(
                child: Text('${property.city}, ${property.country}',
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: AppSizes.fontSm),
                    overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.star, size: 14, color: AppColors.accent),
              const SizedBox(width: 2),
              Text(property.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: AppSizes.fontSm)),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.price(property.price),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontMd,
                    color: AppColors.primary),
              ),
              Row(children: [
                if (property.bedrooms != null)
                  _chip(Icons.bed, '${property.bedrooms}'),
                if (property.bathrooms != null)
                  _chip(Icons.bathtub_outlined, '${property.bathrooms}'),
                if (property.parkingSpaces != null && property.parkingSpaces! > 0)
                  _chip(Icons.local_parking, '${property.parkingSpaces}'),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String val) => Container(
    margin: const EdgeInsets.only(left: AppSizes.xs),
    padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm, vertical: AppSizes.xs),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
    ),
    child: Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textWhite),
        const SizedBox(width: 2),
        Text(val,
            style: const TextStyle(
                color: AppColors.textWhite, fontSize: AppSizes.fontXs)),
      ],
    ),
  );
}
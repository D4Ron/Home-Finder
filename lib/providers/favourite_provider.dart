import 'package:flutter/foundation.dart';
import '../data/models/property_model.dart';
import '../data/services/api_service.dart';
import '../core/constants/api_constants.dart';
import 'property_provider.dart';

class FavouriteProvider with ChangeNotifier {
  final ApiService _api;
  final PropertyProvider _propertyProvider;

  List<PropertyModel> _favourites = [];
  bool _loading = false;
  String? _error;

  FavouriteProvider(this._api, this._propertyProvider);

  List<PropertyModel> get favourites => _favourites;
  bool get loading => _loading;
  String? get error => _error;

  bool isFavourite(int propertyId) =>
      _favourites.any((p) => p.id == propertyId);

  // Alias for use in detail screen
  bool isFavourited(int propertyId) => isFavourite(propertyId);

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get(ApiConstants.favorites);
      _favourites =
          (data as List).map((j) => PropertyModel.fromJson(j)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(PropertyModel property) async {
    final wasFav = isFavourite(property.id);

    // Optimistic update
    if (wasFav) {
      _favourites.removeWhere((p) => p.id == property.id);
    } else {
      _favourites.add(property.copyWith(isFavourited: true));
    }
    _propertyProvider.toggleFavouriteLocally(property.id, !wasFav);
    notifyListeners();

    try {
      if (wasFav) {
        await _api.delete('${ApiConstants.favorites}/${property.id}');
      } else {
        await _api
            .post(ApiConstants.favorites, body: {'propertyId': property.id});
      }
    } catch (e) {
      // Rollback on failure
      if (wasFav) {
        _favourites.add(property);
      } else {
        _favourites.removeWhere((p) => p.id == property.id);
      }
      _propertyProvider.toggleFavouriteLocally(property.id, wasFav);
      _error = e.toString();
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import '../data/models/property_model.dart';
import '../data/services/api_service.dart';
import '../core/constants/api_constants.dart';

class PropertyProvider with ChangeNotifier {
  final ApiService _api;

  List<PropertyModel> _properties = [];
  List<PropertyModel> _myProperties = [];
  PropertyModel? _detail;

  bool _loading = false;
  bool _loadingMore = false;
  bool _detailLoading = false; // ← separate from list loading
  String? _error;

  int _page = 0;
  bool _hasMore = true;

  // Active filters — preserved between loads
  String? _filterCity;
  String? _filterType;
  double? _filterMin;
  double? _filterMax;
  int? _filterBeds;

  PropertyProvider(this._api);

  List<PropertyModel> get properties => _properties;
  List<PropertyModel> get myProperties => _myProperties;
  PropertyModel? get detail => _detail;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get detailLoading => _detailLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  // ── Search / list ──────────────────────────────────────────────────────────

  Future<void> load({
    String? city,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? minBeds,
    bool refresh = false,
  }) async {
    if (refresh) {
      _page = 0;
      _hasMore = true;
      _properties = [];
      _filterCity = city;
      _filterType = type;
      _filterMin = minPrice;
      _filterMax = maxPrice;
      _filterBeds = minBeds;
    }

    if (!_hasMore) return;
    refresh ? _setLoading(true) : _setLoadingMore(true);

    try {
      final data = await _api.post(ApiConstants.propertySearch, body: {
        if (_filterCity != null) 'city': _filterCity,
        if (_filterType != null) 'propertyType': _filterType,
        if (_filterMin != null) 'minPrice': _filterMin,
        if (_filterMax != null) 'maxPrice': _filterMax,
        if (_filterBeds != null) 'minBedrooms': _filterBeds,
        'page': _page,
        'size': 10,
        'sortBy': 'createdAt',
        'sortOrder': 'DESC',
      });

      final list = (data['properties'] as List)
          .map((j) => PropertyModel.fromJson(j))
          .toList();

      _properties.addAll(list);
      _hasMore = list.length == 10;
      _page++;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      refresh ? _setLoading(false) : _setLoadingMore(false);
    }
  }

  Future<void> loadMore() => load();

  Future<void> refresh() => load(refresh: true);

  // ── Detail ─────────────────────────────────────────────────────────────────

  Future<void> loadDetail(int id) async {
    _detailLoading = true;
    _detail = null;
    notifyListeners();
    try {
      final data = await _api.get('${ApiConstants.properties}/$id');
      _detail = PropertyModel.fromJson(data);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _detailLoading = false;
      notifyListeners();
    }
  }

  // ── My listings ────────────────────────────────────────────────────────────

  Future<void> loadMyProperties() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get(ApiConstants.myProperties);
      _myProperties =
          (data as List).map((j) => PropertyModel.fromJson(j)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Optimistic favourite toggle ─────────────────────────────────────────────
  void toggleFavouriteLocally(int propertyId, bool isFav) {
    final idx = _properties.indexWhere((p) => p.id == propertyId);
    if (idx != -1) {
      _properties[idx] = _properties[idx].copyWith(isFavourited: isFav);
    }
    if (_detail?.id == propertyId) {
      _detail = _detail!.copyWith(isFavourited: isFav);
    }
    notifyListeners();
  }

  void clearDetail() {
    _detail = null;
    notifyListeners();
  }

  // ── Internal helpers ────────────────────────────────────────────────────────
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setLoadingMore(bool v) {
    _loadingMore = v;
    notifyListeners();
  }
}

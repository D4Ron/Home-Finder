import 'package:flutter/foundation.dart';
import '../data/models/alert_model.dart';
import '../data/services/api_service.dart';
import '../core/constants/api_constants.dart';

class AlertProvider with ChangeNotifier {
  final ApiService _api;

  List<AlertModel> _alerts = [];
  bool    _loading = false;
  String? _error;

  AlertProvider(this._api);

  List<AlertModel> get alerts  => _alerts;
  bool    get loading  => _loading;
  String? get error    => _error;

  Future<void> loadAlerts() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get(ApiConstants.alerts);
      _alerts = (data as List).map((j) => AlertModel.fromJson(j)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createAlert({
    required String name,
    String? propertyType,
    String? city,
    String? country,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? minBathrooms,
    double? radiusKm,
    String frequency = 'INSTANT',
  }) async {
    try {
      final data = await _api.post(ApiConstants.alerts, body: {
        'name': name,
        if (propertyType != null) 'propertyType': propertyType,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (minBedrooms != null) 'minBedrooms': minBedrooms,
        if (minBathrooms != null) 'minBathrooms': minBathrooms,
        if (radiusKm != null) 'radiusKm': radiusKm,
        'frequency': frequency,
      });
      _alerts.insert(0, AlertModel.fromJson(data));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleAlert(int id) async {
    try {
      final data = await _api.patch(ApiConstants.alertToggle(id));
      final updated = AlertModel.fromJson(data);
      final idx = _alerts.indexWhere((a) => a.id == id);
      if (idx != -1) _alerts[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAlert(int id) async {
    try {
      await _api.delete(ApiConstants.alertById(id));
      _alerts.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
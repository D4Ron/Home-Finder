import 'package:flutter/foundation.dart';
import '../data/models/visit_model.dart';
import '../data/services/api_service.dart';
import '../core/constants/api_constants.dart';

class VisitProvider with ChangeNotifier {
  final ApiService _api;

  List<VisitModel> _myVisits = [];
  List<VisitModel> _propertyVisits = [];
  bool    _loading = false;
  String? _error;

  VisitProvider(this._api);

  List<VisitModel> get myVisits        => _myVisits;
  List<VisitModel> get propertyVisits  => _propertyVisits;
  bool    get loading => _loading;
  String? get error   => _error;

  Future<void> loadMyVisits({String? status}) async {
    _loading = true;
    notifyListeners();
    try {
      var endpoint = ApiConstants.visits;
      if (status != null) endpoint += '?status=$status';
      final data = await _api.get(endpoint);
      _myVisits = (data as List).map((j) => VisitModel.fromJson(j)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadPropertyVisits(int propertyId) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get(ApiConstants.visitsByProperty(propertyId));
      _propertyVisits =
          (data as List).map((j) => VisitModel.fromJson(j)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> scheduleVisit({
    required int propertyId,
    required DateTime scheduledDate,
    String? notes,
  }) async {
    try {
      final data = await _api.post(ApiConstants.visits, body: {
        'propertyId':    propertyId,
        'scheduledDate': scheduledDate.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      _myVisits.insert(0, VisitModel.fromJson(data));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVisitStatus(
      int visitId,
      String status, {
        String? notes,
      }) async {
    try {
      final data = await _api.patch(ApiConstants.visitStatus(visitId), body: {
        'status': status,
        if (notes != null) 'notes': notes,
      });
      final updated = VisitModel.fromJson(data);
      _updateLocal(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelVisit(int visitId, {String? reason}) async {
    try {
      final data = await _api.post(ApiConstants.visitCancel(visitId), body: {
        if (reason != null) 'reason': reason,
      });
      final updated = VisitModel.fromJson(data);
      _updateLocal(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateLocal(VisitModel updated) {
    final idx = _myVisits.indexWhere((v) => v.id == updated.id);
    if (idx != -1) _myVisits[idx] = updated;
    final idx2 = _propertyVisits.indexWhere((v) => v.id == updated.id);
    if (idx2 != -1) _propertyVisits[idx2] = updated;
    notifyListeners();
  }
}
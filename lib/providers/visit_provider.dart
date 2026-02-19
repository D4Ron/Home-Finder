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
      // Backend: GET /visits?status=PENDING (optional query param)
      final Map<String, String>? queryParams =
      status != null ? {'status': status} : null;

      final data = await _api.get(ApiConstants.visits, queryParams: queryParams);
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
      // Backend: PATCH /visits/{id}/status — returns VisitResponse
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
      // Backend: POST /visits/{id}/cancel — returns ApiResponse<Void>, data is null.
      // We do NOT try to parse a VisitModel from this response.
      await _api.post(ApiConstants.visitCancel(visitId), body: {
        if (reason != null) 'reason': reason,
      });

      // Update locally: set the visit status to CANCELLED in both lists
      _cancelLocal(visitId, reason);
      notifyListeners();
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

  /// Called after a successful cancel (backend returns void, so we patch locally)
  void _cancelLocal(int visitId, String? reason) {
    final idx = _myVisits.indexWhere((v) => v.id == visitId);
    if (idx != -1) {
      final v = _myVisits[idx];
      _myVisits[idx] = VisitModel(
        id:               v.id,
        propertyId:       v.propertyId,
        propertyTitle:    v.propertyTitle,
        propertyAddress:  v.propertyAddress,
        propertyImageUrl: v.propertyImageUrl,
        visitorId:        v.visitorId,
        visitorName:      v.visitorName,
        ownerId:          v.ownerId,
        scheduledDate:    v.scheduledDate,
        status:           'CANCELLED',
        notes:            reason ?? v.notes,
        createdAt:        v.createdAt,
      );
    }
    final idx2 = _propertyVisits.indexWhere((v) => v.id == visitId);
    if (idx2 != -1) {
      final v = _propertyVisits[idx2];
      _propertyVisits[idx2] = VisitModel(
        id:               v.id,
        propertyId:       v.propertyId,
        propertyTitle:    v.propertyTitle,
        propertyAddress:  v.propertyAddress,
        propertyImageUrl: v.propertyImageUrl,
        visitorId:        v.visitorId,
        visitorName:      v.visitorName,
        ownerId:          v.ownerId,
        scheduledDate:    v.scheduledDate,
        status:           'CANCELLED',
        notes:            reason ?? v.notes,
        createdAt:        v.createdAt,
      );
    }
  }
}
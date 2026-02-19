import 'package:flutter/foundation.dart';
import '../data/models/message_model.dart';
import '../data/services/api_service.dart';
import '../core/constants/api_constants.dart';

class MessageProvider with ChangeNotifier {
  final ApiService _api;

  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  int _unreadCount = 0;
  bool _loading = false;
  String? _error;

  MessageProvider(this._api);

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadConversations() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get(ApiConstants.conversations);
      _conversations =
          (data as List).map((j) => ConversationModel.fromJson(j)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(int otherUserId, {int? propertyId}) async {
    debugPrint('MessageProvider: loadMessages for user $otherUserId');
    _loading = true;
    notifyListeners();
    try {
      final Map<String, String>? queryParams =
          propertyId != null ? {'propertyId': '$propertyId'} : null;

      final data = await _api.get(
        ApiConstants.conversation(otherUserId),
        queryParams: queryParams,
      );

      _messages = (data as List).map((j) => MessageModel.fromJson(j)).toList();
      debugPrint('MessageProvider: loaded ${_messages.length} messages');
      _error = null;
    } catch (e) {
      debugPrint('MessageProvider: error loading messages: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> send({
    required int receiverId,
    required String content,
    int? propertyId,
  }) async {
    try {
      final data = await _api.post(ApiConstants.messages, body: {
        'receiverId': receiverId,
        'content': content,
        'messageType': 'TEXT',
        if (propertyId != null) 'propertyId': propertyId,
      });
      _messages.add(MessageModel.fromJson(data));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final data = await _api.get(ApiConstants.unreadCount);
      _unreadCount = data as int;
      notifyListeners();
    } catch (_) {}
  }

  void clearMessages() {
    debugPrint('MessageProvider: clearMessages (silent)');
    _messages = [];
  }
}

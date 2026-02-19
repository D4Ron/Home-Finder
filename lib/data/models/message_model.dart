class MessageModel {
  final int id;
  final int senderId;
  final String senderName;
  final String? senderImageUrl;
  final int receiverId;
  final String content;
  final bool read;
  final String messageType;
  final int? propertyId;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.receiverId,
    required this.content,
    required this.read,
    required this.messageType,
    this.propertyId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
        id: j['id'],
        senderId: j['sender']?['id'] ?? j['senderId'] ?? 0,
        senderName: j['sender']?['name'] ?? '',
        senderImageUrl: j['sender']?['profileImageUrl'],
        receiverId: j['receiver']?['id'] ?? j['receiverId'] ?? 0,
        content: j['content'] ?? '',
        read: j['read'] ?? false,
        messageType: j['messageType'] ?? 'TEXT',
        propertyId: j['property']?['id'],
        createdAt: j['createdAt'] != null
            ? DateTime.parse(j['createdAt'])
            : DateTime.now(),
      );
}

/// Maps to Spring Boot's ConversationSummaryResponse which has the shape:
/// {
///   "conversationId": "1_2",
///   "otherUser": { "id": 2, "name": "...", "profileImageUrl": "..." },
///   "property":  { "id": 5, "title": "..." },   ← nullable
///   "lastMessage": "...",
///   "lastMessageDate": "...",
///   "unreadCount": 0,
///   "lastMessageFromMe": false
/// }
class ConversationModel {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserImageUrl;
  final String lastMessage;
  final int unreadCount;
  final DateTime lastMessageAt;
  final int? propertyId;
  final String? propertyTitle;

  const ConversationModel({
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImageUrl,
    required this.lastMessage,
    required this.unreadCount,
    required this.lastMessageAt,
    this.propertyId,
    this.propertyTitle,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> j) {
    // Backend returns nested objects: otherUser{id,name,...} and property{id,title,...}
    final otherUser = j['otherUser'] as Map<String, dynamic>?;
    final property = j['property'] as Map<String, dynamic>?;

    return ConversationModel(
      // Pull from nested otherUser object
      otherUserId: otherUser?['id'] ?? j['otherUserId'] ?? 0,
      otherUserName: otherUser?['name'] ?? j['otherUserName'] ?? '',
      otherUserImageUrl:
          otherUser?['profileImageUrl'] ?? j['otherUserImageUrl'],

      lastMessage: j['lastMessage'] ?? '',
      unreadCount: j['unreadCount'] ?? 0,
      // Backend field is lastMessageDate (not lastMessageAt)
      lastMessageAt: DateTime.parse(j['lastMessageDate'] ?? j['lastMessageAt']),

      // Pull from nested property object
      propertyId: property?['id'] ?? j['propertyId'],
      propertyTitle: property?['title'] ?? j['propertyTitle'],
    );
  }
}

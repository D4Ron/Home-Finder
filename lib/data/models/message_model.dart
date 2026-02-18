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
    senderId: j['sender']?['id'] ?? j['senderId'],
    senderName: j['sender']?['name'] ?? '',
    senderImageUrl: j['sender']?['profileImageUrl'],
    receiverId: j['receiver']?['id'] ?? j['receiverId'],
    content: j['content'],
    read: j['read'] ?? false,
    messageType: j['messageType'] ?? 'TEXT',
    propertyId: j['property']?['id'],
    createdAt: DateTime.parse(j['createdAt']),
  );
}

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

  factory ConversationModel.fromJson(Map<String, dynamic> j) =>
      ConversationModel(
        otherUserId: j['otherUserId'],
        otherUserName: j['otherUserName'],
        otherUserImageUrl: j['otherUserImageUrl'],
        lastMessage: j['lastMessage'],
        unreadCount: j['unreadCount'] ?? 0,
        lastMessageAt: DateTime.parse(j['lastMessageAt']),
        propertyId: j['propertyId'],
        propertyTitle: j['propertyTitle'],
      );
}
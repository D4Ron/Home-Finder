import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/message_model.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;
  final int? propertyId;
  final String? propertyTitle;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.propertyId,
    this.propertyTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late MessageProvider _msgProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _msgProvider = context.read<MessageProvider>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadMessages(
            widget.otherUserId,
            propertyId: widget.propertyId,
          );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    Future.microtask(() => _msgProvider.clearMessages());
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    await context.read<MessageProvider>().send(
          receiverId: widget.otherUserId,
          content: text,
          propertyId: widget.propertyId,
        );
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.read<AuthProvider>().user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (widget.propertyTitle != null)
              Text(widget.propertyTitle!,
                  style: const TextStyle(
                      fontSize: AppSizes.fontSm, color: AppColors.textGrey)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(builder: (_, mp, __) {
              if (mp.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(AppSizes.md),
                itemCount: mp.messages.length,
                itemBuilder: (_, i) => _Bubble(
                  message: mp.messages[i],
                  isMe: mp.messages[i].senderId == myId,
                ),
              );
            }),
          ),
          _InputBar(ctrl: _ctrl, onSend: _send),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  const _Bubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppSizes.radiusMd),
            topRight: const Radius.circular(AppSizes.radiusMd),
            bottomLeft: Radius.circular(isMe ? AppSizes.radiusMd : 0),
            bottomRight: Radius.circular(isMe ? 0 : AppSizes.radiusMd),
          ),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.content,
                style: TextStyle(
                    color: isMe ? AppColors.textWhite : AppColors.textDark)),
            const SizedBox(height: 2),
            Text(Formatters.timeAgo(message.createdAt),
                style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: isMe ? Colors.white60 : AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSend;
  const _InputBar({required this.ctrl, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md,
          AppSizes.sm + MediaQuery.of(context).viewInsets.bottom),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: AppStrings.typeMessage,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.sm),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon:
                  const Icon(Icons.send, color: AppColors.textWhite, size: 20),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

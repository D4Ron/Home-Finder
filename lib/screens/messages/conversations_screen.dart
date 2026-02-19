import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/message_provider.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.messages,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<MessageProvider>(builder: (_, mp, __) {
        if (mp.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (mp.conversations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 64, color: AppColors.textLight),
                SizedBox(height: AppSizes.md),
                Text('Aucune conversation',
                    style: TextStyle(color: AppColors.textGrey)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: mp.loadConversations,
          child: ListView.separated(
            itemCount: mp.conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = mp.conversations[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: c.otherUserImageUrl != null
                      ? NetworkImage(c.otherUserImageUrl!)
                      : const AssetImage('assets/images/profile.jpeg')
                          as ImageProvider,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(c.otherUserName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(Formatters.timeAgo(c.lastMessageAt),
                        style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: AppSizes.fontXs)),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(c.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textGrey)),
                    ),
                    if (c.unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(left: AppSizes.xs),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        child: Text('${c.unreadCount}',
                            style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: AppSizes.fontXs)),
                      ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      otherUserId: c.otherUserId,
                      otherUserName: c.otherUserName,
                      propertyId: c.propertyId,
                      propertyTitle: c.propertyTitle,
                    ),
                  ),
                ).then(
                    (_) => context.read<MessageProvider>().loadConversations()),
              );
            },
          ),
        );
      }),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthProvider>(builder: (_, auth, __) {
        final user = auth.user;
        if (user == null) return const SizedBox.shrink();

        return CustomScrollView(
          slivers: [
            _Header(user: user),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.lg),
                  _Section(children: [
                    _Item(
                      icon: Icons.grid_view,
                      label: AppStrings.myListings,
                      onTap: () {},
                    ),
                    _Item(
                      icon: Icons.favorite_border,
                      label: AppStrings.savedItems,
                      onTap: () {},
                    ),
                    _Item(
                      icon: Icons.calendar_today_outlined,
                      label: AppStrings.visits,
                      onTap: () {},
                    ),
                    _Item(
                      icon: Icons.chat_bubble_outline,
                      label: AppStrings.chats,
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: AppSizes.md),
                  _Section(children: [
                    _Item(
                      icon: Icons.settings_outlined,
                      label: AppStrings.settings,
                      onTap: () {},
                    ),
                    _Item(
                      icon: Icons.star_border,
                      label: AppStrings.becomeAgent,
                      onTap: () {},
                    ),
                    _Item(
                      icon: Icons.people_outline,
                      label: AppStrings.invite,
                      onTap: () {},
                    ),
                    _Item(
                      icon: Icons.help_outline,
                      label: AppStrings.helpCenter,
                      onTap: () {},
                    ),
                    _Item(
                      icon: Icons.info_outline,
                      label: AppStrings.about,
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: AppSizes.md),
                  _Section(children: [
                    _Item(
                      icon: Icons.logout,
                      label: AppStrings.logout,
                      color: AppColors.error,
                      onTap: () => _confirmLogout(context, auth),
                    ),
                  ]),
                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Vous serez redirigé vers la page de connexion.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
            },
            child: Text(AppStrings.logout,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Profile SliverAppBar ──────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final dynamic user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSizes.lg),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: AppSizes.avatarLg / 2,
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl)
                          : const AssetImage('assets/images/profile.jpeg')
                      as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfileScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.xs),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 16, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Text(user.name,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: AppSizes.fontXl,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSizes.xs),
                Text(user.email,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: AppSizes.fontSm)),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Membre depuis ${Formatters.date(user.createdAt)}',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: AppSizes.fontXs),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Menu section card ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final List<Widget> children;
  const _Section({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(children: children),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color?   color;
  final VoidCallback onTap;
  const _Item({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textDark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
      onTap: onTap,
    );
  }
}
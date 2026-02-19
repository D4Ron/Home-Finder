import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/visit_model.dart';
import '../../providers/visit_provider.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  static const _tabs = ['Toutes', 'En attente', 'Confirmées', 'Terminées'];
  static const _statuses = [null, 'PENDING', 'CONFIRMED', 'COMPLETED'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitProvider>().loadMyVisits();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Visites',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Consumer<VisitProvider>(builder: (_, vp, __) {
        if (vp.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabCtrl,
          children: _statuses.map((status) {
            final visits = status == null
                ? vp.myVisits
                : vp.myVisits.where((v) => v.status == status).toList();

            if (visits.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 56, color: AppColors.textLight),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'Aucune visite ${status != null ? _tabs[_statuses.indexOf(status)].toLowerCase() : ''}',
                      style:
                      const TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => vp.loadMyVisits(status: status),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.md),
                itemCount: visits.length,
                itemBuilder: (_, i) => _VisitCard(
                  visit: visits[i],
                  onCancel: () => _confirmCancel(visits[i]),
                  onStatusChange: (s) => _changeStatus(visits[i], s),
                ),
              ),
            );
          }).toList(),
        );
      }),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  void _confirmCancel(VisitModel visit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Annuler la visite ?'),
        content: const Text('Cette action ne peut pas être annulée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<VisitProvider>().cancelVisit(
                visit.id,
                reason: 'Annulée par l\'utilisateur',
              );
            },
            child: const Text('Oui, annuler',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _changeStatus(VisitModel visit, String status) async {
    await context.read<VisitProvider>().updateVisitStatus(visit.id, status);
  }
}

class _VisitCard extends StatelessWidget {
  final VisitModel visit;
  final VoidCallback onCancel;
  final void Function(String) onStatusChange;

  const _VisitCard({
    required this.visit,
    required this.onCancel,
    required this.onStatusChange,
  });

  Color get _statusColor => switch (visit.status) {
    'PENDING'   => Colors.orange,
    'CONFIRMED' => AppColors.success,
    'CANCELLED' => AppColors.error,
    'COMPLETED' => AppColors.textGrey,
    _ => AppColors.textGrey,
  };

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy · HH:mm', 'fr_FR');
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property image
          if (visit.propertyImageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusLg)),
              child: Image.network(
                visit.propertyImageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  color: AppColors.background,
                  child: const Icon(Icons.home,
                      size: 48, color: AppColors.textLight),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        visit.propertyTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.fontMd),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.12),
                        borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        visit.statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                if (visit.propertyAddress != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          visit.propertyAddress!,
                          style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: AppSizes.fontSm),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      fmt.format(visit.scheduledDate),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.fontSm),
                    ),
                  ],
                ),
                if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    visit.notes!,
                    style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: AppSizes.fontSm),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Actions
                if (visit.status == 'PENDING') ...[
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side:
                            const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => onStatusChange('CONFIRMED'),
                          child: const Text('Confirmer'),
                        ),
                      ),
                    ],
                  ),
                ] else if (visit.status == 'CONFIRMED') ...[
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side:
                            const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => onStatusChange('COMPLETED'),
                          child: const Text('Marquer effectuée'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
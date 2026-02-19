import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/alert_model.dart';
import '../../providers/alert_provider.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Alertes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAlert(context),
          ),
        ],
      ),
      body: Consumer<AlertProvider>(builder: (_, ap, __) {
        if (ap.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ap.alerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notifications_none,
                    size: 64, color: AppColors.textLight),
                const SizedBox(height: AppSizes.md),
                const Text('Aucune alerte créée',
                    style: TextStyle(color: AppColors.textGrey)),
                const SizedBox(height: AppSizes.md),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Créer une alerte'),
                  onPressed: () => _showCreateAlert(context),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ap.loadAlerts,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: ap.alerts.length,
            itemBuilder: (_, i) => _AlertCard(alert: ap.alerts[i]),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateAlert(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateAlert(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (_) => const _CreateAlertSheet(),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.md),
        leading: Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            alert.active
                ? Icons.notifications_active
                : Icons.notifications_off_outlined,
            color: alert.active ? AppColors.primary : AppColors.textGrey,
          ),
        ),
        title: Text(alert.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (alert.city != null)
              Text(alert.city!,
                  style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: AppSizes.fontSm)),
            Text(
              alert.frequencyLabel,
              style: const TextStyle(
                  color: AppColors.primary, fontSize: AppSizes.fontXs),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: alert.active,
              onChanged: (_) =>
                  context.read<AlertProvider>().toggleAlert(alert.id),
              activeColor: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'alerte ?'),
        content: Text('Supprimer "${alert.name}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AlertProvider>().deleteAlert(alert.id);
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _CreateAlertSheet extends StatefulWidget {
  const _CreateAlertSheet();

  @override
  State<_CreateAlertSheet> createState() => _CreateAlertSheetState();
}

class _CreateAlertSheetState extends State<_CreateAlertSheet> {
  final _nameCtrl  = TextEditingController();
  final _cityCtrl  = TextEditingController();
  final _minCtrl   = TextEditingController();
  final _maxCtrl   = TextEditingController();
  String? _selectedType;
  String _frequency = 'INSTANT';
  bool _submitting = false;

  static const _types = {
    null:        'Tous',
    'HOUSE':     'Maison',
    'APARTMENT': 'Appartement',
    'VILLA':     'Villa',
    'LAND':      'Terrain',
  };

  static const _freqOptions = {
    'INSTANT': 'Instantané',
    'DAILY':   'Quotidien',
    'WEEKLY':  'Hebdomadaire',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom est requis'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _submitting = true);
    final ok = await context.read<AlertProvider>().createAlert(
      name: _nameCtrl.text.trim(),
      propertyType: _selectedType,
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      minPrice: double.tryParse(_minCtrl.text.replaceAll(' ', '')),
      maxPrice: double.tryParse(_maxCtrl.text.replaceAll(' ', '')),
      frequency: _frequency,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.lg, AppSizes.lg, AppSizes.lg,
        AppSizes.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            const Text('Nouvelle alerte',
                style: TextStyle(
                    fontSize: AppSizes.fontXl, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.lg),

            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nom de l\'alerte *',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _cityCtrl,
              decoration: InputDecoration(
                labelText: 'Ville',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            const Text('Type de bien',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              children: _types.entries.map((e) {
                final sel = _selectedType == e.key;
                return ChoiceChip(
                  label: Text(e.value),
                  selected: sel,
                  onSelected: (_) =>
                      setState(() => _selectedType = e.key),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: sel
                          ? AppColors.textWhite
                          : AppColors.textDark),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.md),

            const Text('Prix (Fcfa)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSizes.sm),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _minCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Min',
                    border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd)),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
                child: Text('—'),
              ),
              Expanded(
                child: TextField(
                  controller: _maxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max',
                    border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd)),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: AppSizes.md),

            const Text('Fréquence',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              children: _freqOptions.entries.map((e) {
                final sel = _frequency == e.key;
                return ChoiceChip(
                  label: Text(e.value),
                  selected: sel,
                  onSelected: (_) =>
                      setState(() => _frequency = e.key),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: sel
                          ? AppColors.textWhite
                          : AppColors.textDark),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.xl),

            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonH,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation(Colors.white)))
                    : const Text('Créer l\'alerte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
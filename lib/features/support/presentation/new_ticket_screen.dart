import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/support_repository.dart';

class NewTicketScreen extends ConsumerStatefulWidget {
  const NewTicketScreen({super.key});

  @override
  ConsumerState<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends ConsumerState<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = 'general';
  bool _submitting = false;

  static const _categories = [
    'payment',
    'consultation',
    'kyc',
    'puja',
    'order',
    'general',
  ];

  String _categoryLabel(AppLocalizations l10n, String cat) => switch (cat) {
        'payment' => l10n.categoryPayment,
        'consultation' => l10n.categoryConsultation,
        'kyc' => l10n.categoryKyc,
        'puja' => l10n.categoryPuja,
        'order' => l10n.categoryOrder,
        _ => l10n.categoryGeneral,
      };

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(ticketsNotifierProvider.notifier).createTicket(
            category: _category,
            subject: _subjectCtrl.text.trim(),
            description: _descCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).ticketCreated),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorGeneric),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(l10n.newTicketTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.categoryLabel,
              style: tt.labelMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final selected = cat == _category;
                return ChoiceChip(
                  label: Text(_categoryLabel(l10n, cat)),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = cat),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.cardDark,
                  labelStyle: tt.labelMedium?.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppColors.primary
                        : AppColors.borderDark,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.subjectLabel,
              style: tt.labelMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectCtrl,
              style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
              decoration: _inputDecoration(l10n.subjectHint),
              validator: (v) {
                if (v == null || v.trim().length < 5) {
                  return 'Subject must be at least 5 characters';
                }
                return null;
              },
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.descriptionLabel,
              style: tt.labelMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
              decoration: _inputDecoration(l10n.descriptionHint),
              minLines: 5,
              maxLines: 10,
              validator: (v) {
                if (v == null || v.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
              maxLength: 2000,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      l10n.submitTicket,
                      style: tt.labelLarge?.copyWith(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textDisabled),
      filled: true,
      fillColor: AppColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}

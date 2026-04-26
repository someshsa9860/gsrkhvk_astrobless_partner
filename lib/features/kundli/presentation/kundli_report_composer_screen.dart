import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/kundli_repository.dart';
import 'kundli_controller.dart';

class KundliReportComposerScreen extends ConsumerStatefulWidget {
  const KundliReportComposerScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<KundliReportComposerScreen> createState() =>
      _KundliReportComposerScreenState();
}

class _KundliReportComposerScreenState
    extends ConsumerState<KundliReportComposerScreen> {
  final _ctrl = TextEditingController();
  bool _submitting = false;
  bool _previewing = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill if report already started
    final existing = ref.read(kundliRequestDetailProvider(widget.id)).valueOrNull;
    if (existing?.reportText != null) {
      _ctrl.text = existing!.reportText!;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    final l10n = AppLocalizations.of(context);
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reportCannotBeEmpty),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() => _submitting = true);
    try {
      await ref.read(kundliRepositoryProvider).submitReport(widget.id, text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).reportSubmittedNotice),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.kundliRequests);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<bool> _showConfirmDialog() async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.cardDark,
            title: Text(l10n.submitReportTitle, style: const TextStyle(color: AppColors.textPrimary)),
            content: Text(
              l10n.submitReportBody,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel, style: const TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(l10n.submit, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final requestState = ref.watch(kundliRequestDetailProvider(widget.id));
    final customerName = requestState.valueOrNull?.customerName ?? 'Customer';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(_previewing ? AppLocalizations.of(context).previewLabel : AppLocalizations.of(context).writeReport),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_previewing) {
              setState(() => _previewing = false);
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _previewing = !_previewing),
            child: Text(
              _previewing ? AppLocalizations.of(context).editLabel : AppLocalizations.of(context).previewLabel,
              style: const TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceDark,
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Report for $customerName',
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                ValueListenableBuilder(
                  valueListenable: _ctrl,
                  builder: (_, v, __) => Text(
                    '${v.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
                    style: tt.labelSmall?.copyWith(color: AppColors.textDisabled),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),
          Expanded(
            child: _previewing
                ? _PreviewPane(text: _ctrl.text)
                : _EditorPane(controller: _ctrl),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          AppLocalizations.of(context).submitReportTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorPane extends StatelessWidget {
  const _EditorPane({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.6,
        ),
        decoration: InputDecoration(
          hintText:
              'Write the Kundli interpretation here...\n\nInclude:\n• Lagna (Ascendant) analysis\n• Planetary positions & their effects\n• Key Dashas & their predictions\n• Recommendations & remedies',
          hintStyle: TextStyle(color: AppColors.textDisabled.withValues(alpha: 0.6), height: 1.6),
          filled: true,
          fillColor: AppColors.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _PreviewPane extends StatelessWidget {
  const _PreviewPane({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    if (text.trim().isEmpty) {
      return Center(
        child: Text(
          'Nothing to preview yet',
          style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Text(
          text,
          style: tt.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            height: 1.7,
          ),
        ),
      ),
    );
  }
}

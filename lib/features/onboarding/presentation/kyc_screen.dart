import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';

enum _DocType { aadhaarFront, aadhaarBack, pan }

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final Map<_DocType, String?> _uploaded = {};
  bool _submitting = false;

  bool get _canSubmit =>
      _uploaded[_DocType.aadhaarFront] != null &&
      _uploaded[_DocType.aadhaarBack] != null &&
      _uploaded[_DocType.pan] != null;

  Future<void> _pickAndUpload(_DocType docType) async {
    // In production: ImagePicker → get pre-signed URL → upload to S3 → confirm
    // Here we simulate a successful upload so the UI is wired correctly.
    setState(() => _uploaded[docType] = 'uploaded_${docType.name}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_docLabel(docType)} uploaded'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/kyc/submit');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KYC submitted — our team will review within 24 hours'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(extractException(e).message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _docLabel(_DocType t) => switch (t) {
        _DocType.aadhaarFront => 'Aadhaar (Front)',
        _DocType.aadhaarBack => 'Aadhaar (Back)',
        _DocType.pan => 'PAN Card',
      };

  String _docHint(_DocType t) => switch (t) {
        _DocType.aadhaarFront => 'Front side of your Aadhaar card',
        _DocType.aadhaarBack => 'Back side of your Aadhaar card',
        _DocType.pan => 'PAN card (government-issued)',
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: const Text('KYC Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'KYC is required to start receiving consultations. Documents are reviewed within 24 hours.',
                        style: tt.bodySmall?.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 28),
              Text(
                'Upload Documents',
                style: tt.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(delay: 80.ms),
              const SizedBox(height: 6),
              Text(
                'Upload clear photos of your identity documents.',
                style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),
              ..._DocType.values.asMap().entries.map(
                    (e) => _DocUploadTile(
                      label: _docLabel(e.value),
                      hint: _docHint(e.value),
                      isUploaded: _uploaded[e.value] != null,
                      onTap: () => _pickAndUpload(e.value),
                    )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 140 + e.key * 60))
                        .slideX(begin: 0.05),
                  ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_canSubmit && !_submitting) ? _submit : null,
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
                      : const Text(
                          'Submit for Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 320.ms),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Your documents are encrypted and securely stored.',
                  style: tt.bodySmall?.copyWith(color: AppColors.textDisabled),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 360.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocUploadTile extends StatelessWidget {
  const _DocUploadTile({
    required this.label,
    required this.hint,
    required this.isUploaded,
    required this.onTap,
  });

  final String label;
  final String hint;
  final bool isUploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = isUploaded ? AppColors.success : AppColors.primary;

    return GestureDetector(
      onTap: isUploaded ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded
                ? AppColors.success.withValues(alpha: 0.5)
                : AppColors.borderDark,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_outline : Icons.upload_file_outlined,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploaded ? 'Uploaded successfully' : hint,
                    style: tt.bodySmall?.copyWith(
                      color: isUploaded ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isUploaded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Upload',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

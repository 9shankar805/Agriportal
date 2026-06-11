import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/firestore_service.dart';
import '../../core/imgbb_service.dart';
import '../../core/user_session.dart';
import '../../widgets/custom_icon_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KYC Verification Screen
// Real document upload via image_picker + ImgBB
// URLs stored in Firestore under users/{uid}/kycDocuments
// ─────────────────────────────────────────────────────────────────────────────

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _streetCtrl     = TextEditingController();
  final _cityCtrl       = TextEditingController();
  final _districtCtrl   = TextEditingController();
  final _provinceCtrl   = TextEditingController();
  final _wardCtrl       = TextEditingController();

  // Uploaded image URLs
  String? _frontUrl;
  String? _backUrl;
  String? _selfieUrl;

  // Per-slot upload state
  bool _uploadingFront   = false;
  bool _uploadingBack    = false;
  bool _uploadingSelfie  = false;

  bool _isSubmitted  = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _provinceCtrl.dispose();
    _wardCtrl.dispose();
    super.dispose();
  }

  // ── Image pick + upload ─────────────────────────────────────────────────

  Future<void> _pickAndUpload(String slot) async {
    final picker = ImagePicker();

    // For selfie, offer camera; for documents, gallery
    final source = slot == 'selfie' ? ImageSource.camera : ImageSource.gallery;

    // Show choice for selfie
    ImageSource? chosen = source;
    if (slot == 'selfie') {
      chosen = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _SourcePickerSheet(),
      );
      if (chosen == null) return;
    }

    final picked = await picker.pickImage(
      source: chosen,
      imageQuality: 75,
      maxWidth: 1200,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      if (slot == 'front')  _uploadingFront   = true;
      if (slot == 'back')   _uploadingBack    = true;
      if (slot == 'selfie') _uploadingSelfie  = true;
    });

    try {
      final url = await ImgBBService.instance.uploadImage(
        file,
        name: 'kyc_${slot}_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        setState(() {
          if (slot == 'front')  _frontUrl  = url;
          if (slot == 'back')   _backUrl   = url;
          if (slot == 'selfie') _selfieUrl = url;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Upload failed: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          if (slot == 'front')  _uploadingFront   = false;
          if (slot == 'back')   _uploadingBack    = false;
          if (slot == 'selfie') _uploadingSelfie  = false;
        });
      }
    }
  }

  // ── Submit ──────────────────────────────────────────────────────────────

  Future<void> _submitForApproval() async {
    if (!_formKey.currentState!.validate()) return;

    if (_frontUrl == null || _backUrl == null || _selfieUrl == null) {
      _showSnack('Please upload all required documents.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final uid = UserSession.instance.uid;
    if (uid.isEmpty) {
      _showSnack('Please sign in first.', isError: true);
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      await FirestoreService.instance.submitKyc(
        uid: uid,
        addressData: {
          'street':   _streetCtrl.text.trim(),
          'city':     _cityCtrl.text.trim(),
          'district': _districtCtrl.text.trim(),
          'province': _provinceCtrl.text.trim(),
          'ward':     _wardCtrl.text.trim(),
        },
        documents: {
          'citizenshipFront': _frontUrl!,
          'citizenshipBack':  _backUrl!,
          'selfie':           _selfieUrl!,
        },
      );
      if (mounted) setState(() { _isSubmitted = true; _isSubmitting = false; });
    } catch (e) {
      if (mounted) {
        _showSnack('Submission error: $e', isError: true);
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'KYC Verification',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: _isSubmitted ? _buildSuccess(theme) : _buildForm(theme),
    );
  }

  // ── Success state ───────────────────────────────────────────────────────

  Widget _buildSuccess(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'hourglass_top',
                  color: theme.colorScheme.primary,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Submitted for Review',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your KYC documents and photos have been uploaded and submitted. Our admin team will verify your documents within 1–2 business days.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: theme.colorScheme.outline,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'info_outline',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'You can apply for land once approved.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Form ────────────────────────────────────────────────────────────────

  Widget _buildForm(ThemeData theme) {
    final allDocsUploaded =
        _frontUrl != null && _backUrl != null && _selfieUrl != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(60),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomIconWidget(
                    iconName: 'shield',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Upload your Citizenship ID and a selfie. Documents are securely stored and reviewed by our admin team.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildProgressRow(theme),
            const SizedBox(height: 24),

            // ── Citizenship Documents ──────────────────────────────────────
            _buildSectionHeader(theme, 'Citizenship ID', 'badge'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoSlot(
                    theme,
                    label: 'Front Side',
                    icon: 'credit_card',
                    uploadedUrl: _frontUrl,
                    isUploading: _uploadingFront,
                    onTap: () => _pickAndUpload('front'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPhotoSlot(
                    theme,
                    label: 'Back Side',
                    icon: 'flip_to_back',
                    uploadedUrl: _backUrl,
                    isUploading: _uploadingBack,
                    onTap: () => _pickAndUpload('back'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Selfie ────────────────────────────────────────────────────
            _buildSectionHeader(theme, 'Selfie Verification', 'face'),
            const SizedBox(height: 12),
            _buildPhotoSlot(
              theme,
              label: 'Clear selfie with face visible',
              icon: 'camera_alt',
              uploadedUrl: _selfieUrl,
              isUploading: _uploadingSelfie,
              onTap: () => _pickAndUpload('selfie'),
              fullWidth: true,
              hint: 'No sunglasses. Face clearly visible.',
            ),

            const SizedBox(height: 24),

            // ── Address ───────────────────────────────────────────────────
            _buildSectionHeader(theme, 'Address Information', 'location_on'),
            const SizedBox(height: 12),

            _buildTextField(theme, _streetCtrl, 'Street / Tole', 'home',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    theme, _wardCtrl, 'Ward No.', 'tag',
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    theme, _cityCtrl, 'Municipality / City', 'location_city',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    theme, _districtCtrl, 'District', 'map',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    theme, _provinceCtrl, 'Province', 'terrain',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForApproval,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allDocsUploaded
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'send',
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Submit for Admin Approval',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Photo slot ──────────────────────────────────────────────────────────

  Widget _buildPhotoSlot(
    ThemeData theme, {
    required String label,
    required String icon,
    required String? uploadedUrl,
    required bool isUploading,
    required VoidCallback onTap,
    bool fullWidth = false,
    String? hint,
  }) {
    final uploaded = uploadedUrl != null;

    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: fullWidth ? double.infinity : null,
        height: fullWidth ? 120 : 140,
        decoration: BoxDecoration(
          color: uploaded
              ? theme.colorScheme.primaryContainer.withAlpha(80)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: uploaded
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: uploaded ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: isUploading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : uploaded
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(uploadedUrl ?? '', fit: BoxFit.cover),
                      // Success overlay
                      Positioned(
                        top: 6, right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'check',
                                color: Colors.white,
                                size: 10,
                              ),
                              const SizedBox(width: 3),
                              Text('Uploaded',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      // Retake button
                      Positioned(
                        bottom: 6, right: 6,
                        child: GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(140),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('Retake',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: icon,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (hint != null) ...[
                        const SizedBox(height: 3),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            hint,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: theme.colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Tap to upload',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  // ── Progress row ────────────────────────────────────────────────────────

  Widget _buildProgressRow(ThemeData theme) {
    final steps = [
      {'label': 'ID Front', 'done': _frontUrl != null},
      {'label': 'ID Back',  'done': _backUrl  != null},
      {'label': 'Selfie',   'done': _selfieUrl != null},
      {
        'label': 'Address',
        'done': _streetCtrl.text.isNotEmpty && _cityCtrl.text.isNotEmpty,
      },
    ];
    return Row(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isDone = step['done'] as bool;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: isDone
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isDone
                            ? CustomIconWidget(
                                iconName: 'check', color: Colors.white, size: 14)
                            : Text('${i + 1}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface.withAlpha(120),
                                )),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['label'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight:
                            isDone ? FontWeight.w600 : FontWeight.w400,
                        color: isDone
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: isDone
                        ? theme.colorScheme.primary.withAlpha(120)
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String icon) {
    return Row(
      children: [
        CustomIconWidget(iconName: icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    TextEditingController controller,
    String label,
    String icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.plusJakartaSans(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: CustomIconWidget(iconName: icon, color: theme.colorScheme.outline, size: 18),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Camera / Gallery source picker
// ─────────────────────────────────────────────────────────────────────────────

class _SourcePickerSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withAlpha(70),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Choose Photo Source',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SourceOption(
                  icon: 'camera_alt',
                  label: 'Camera',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SourceOption(
                  icon: 'photo_library',
                  label: 'Gallery',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha(60),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                )),
          ],
        ),
      ),
    );
  }
}

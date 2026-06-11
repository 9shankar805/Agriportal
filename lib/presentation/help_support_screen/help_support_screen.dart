import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FAQ Model
// ─────────────────────────────────────────────────────────────────────────────

class FaqItem {
  final String question;
  final String answer;
  final String category;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    required this.category,
    this.isExpanded = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Seed FAQ data
// ─────────────────────────────────────────────────────────────────────────────

List<FaqItem> _seedFaqs() => [
      FaqItem(
        question: 'How do I apply for a land listing?',
        answer:
            'Browse available lands on the Explore tab. Tap a land card to view its details, then tap "Apply Now". Fill in your farming experience, intended crops, and proposal. Your application is reviewed by the admin before being shared with the land owner.',
        category: 'Applications',
      ),
      FaqItem(
        question: 'What is KYC verification and why is it required?',
        answer:
            'KYC (Know Your Customer) verification confirms your identity. It is required before you can apply for any land. You need to upload your Citizenship ID (front and back), a selfie, and your current address. Our admin team reviews it within 1–2 business days.',
        category: 'Verification',
      ),
      FaqItem(
        question: 'How long does admin review take?',
        answer:
            'KYC verification is reviewed within 1–2 business days. Land applications are reviewed within 2–3 business days. You will receive a notification once a decision is made.',
        category: 'Applications',
      ),
      FaqItem(
        question: 'Can I contact a land owner directly?',
        answer:
            'Yes! Once your application is approved by the admin, the land owner\'s contact details are revealed and you can message them directly through the in-app chat.',
        category: 'Chat',
      ),
      FaqItem(
        question: 'How do I list my land as a land owner?',
        answer:
            'Select "Land Owner" during sign-in. In the My Lands tab, tap the "+" button to add your listing. Fill in the land details including area, soil type, water source, and lease price. Your listing will be reviewed by the admin before going live.',
        category: 'Listing',
      ),
      FaqItem(
        question: 'What happens if my application is rejected?',
        answer:
            'You will receive a notification with the reason for rejection. You are allowed to update your application and reapply after 7 days, or apply for a different land listing.',
        category: 'Applications',
      ),
      FaqItem(
        question: 'How is my personal information protected?',
        answer:
            'AgriPortal keeps your contact details private until your application is approved. All documents are encrypted and stored securely. We do not share your information with third parties without your consent.',
        category: 'Privacy',
      ),
      FaqItem(
        question: 'How do I report a fraudulent listing?',
        answer:
            'Tap the three-dot menu on any land detail page and select "Report Listing". Our team investigates all reports within 24 hours. Listings found to be fraudulent are immediately removed.',
        category: 'Safety',
      ),
    ];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isSubmitting = false;
  bool _submitted = false;
  String _faqSearch = '';

  late List<FaqItem> _faqs;

  final List<String> _categories = [
    'General',
    'Applications',
    'Payment',
    'Technical',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _faqs = _seedFaqs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  List<FaqItem> get _filteredFaqs {
    if (_faqSearch.isEmpty) return _faqs;
    final q = _faqSearch.toLowerCase();
    return _faqs
        .where((f) =>
            f.question.toLowerCase().contains(q) ||
            f.answer.toLowerCase().contains(q))
        .toList();
  }

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
          'Help & Support',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.outline,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Contact Us'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFaqTab(theme),
          _buildContactTab(theme),
        ],
      ),
    );
  }

  // ── FAQ Tab ────────────────────────────────────────────────────────────────

  Widget _buildFaqTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          child: TextField(
            onChanged: (v) => setState(() => _faqSearch = v),
            style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: 'Search frequently asked questions...',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: theme.colorScheme.outline,
                  size: 18,
                ),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
          ),
        ),
        Expanded(
          child: _filteredFaqs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'search_off',
                        color: theme.colorScheme.outline,
                        size: 48,
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        'No FAQs matched your search',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  itemCount: _filteredFaqs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final faq = _filteredFaqs[index];
                    return _FaqCard(
                      faq: faq,
                      onToggle: () => setState(() {
                        faq.isExpanded = !faq.isExpanded;
                      }),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Contact Tab ────────────────────────────────────────────────────────────

  Widget _buildContactTab(ThemeData theme) {
    if (_submitted) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.primary,
                    size: 40,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Message Sent!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Our support team will get back to you within 24 hours. Check your email for the confirmation.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: theme.colorScheme.outline,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick contact cards
          Row(
            children: [
              Expanded(
                child: _ContactOptionCard(
                  icon: 'email',
                  label: 'Email Us',
                  value: 'support@agriportal.np',
                  color: const Color(0xFF1565C0),
                  bgColor: const Color(0xFFE3F2FD),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _ContactOptionCard(
                  icon: 'call',
                  label: 'Call Us',
                  value: '+977 01-4XXXXXX',
                  color: AppTheme.primary,
                  bgColor: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          Text(
            'Send a Message',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),

          // Name field
          _buildTextField(theme, _nameController, 'Your Name', 'person_outline'),
          SizedBox(height: 1.5.h),

          // Email field
          _buildTextField(
            theme,
            _emailController,
            'Email Address',
            'email',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 1.5.h),

          // Category dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                icon: CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: theme.colorScheme.outline,
                  size: 22,
                ),
                items: _categories
                    .map((c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(
                            c,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
                hint: Text(
                  'Category',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),

          // Message field
          TextFormField(
            controller: _messageController,
            maxLines: 5,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
            decoration: InputDecoration(
              labelText: 'Message',
              hintText: 'Describe your issue or question in detail...',
              alignLabelWithHint: true,
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
          ),
          SizedBox(height: 2.5.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_nameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _messageController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please fill in all fields.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            ),
                            backgroundColor: theme.colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() => _isSubmitting = true);
                      try {
                        await FirestoreService.instance.sendSupportMessage(
                          name:     _nameController.text.trim(),
                          email:    _emailController.text.trim(),
                          category: _selectedCategory,
                          message:  _messageController.text.trim(),
                        );
                        if (mounted) {
                          setState(() {
                            _isSubmitting = false;
                            _submitted = true;
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to send: $e',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                              backgroundColor: theme.colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
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
                        SizedBox(width: 2.w),
                        Text(
                          'Send Message',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    TextEditingController controller,
    String label,
    String iconName, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: CustomIconWidget(
            iconName: iconName,
            color: theme.colorScheme.outline,
            size: 18,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAQ Card (expandable)
// ─────────────────────────────────────────────────────────────────────────────

class _FaqCard extends StatelessWidget {
  final FaqItem faq;
  final VoidCallback onToggle;

  const _FaqCard({required this.faq, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: faq.isExpanded
              ? theme.colorScheme.primary.withAlpha(80)
              : theme.colorScheme.outlineVariant.withAlpha(80),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      faq.category,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  AnimatedRotation(
                    turns: faq.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomIconWidget(
                      iconName: 'expand_more',
                      color: faq.isExpanded
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      size: 20,
                    ),
                  ),
                ],
              ),
              if (faq.isExpanded) ...[
                SizedBox(height: 1.2.h),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withAlpha(80),
                ),
                SizedBox(height: 1.2.h),
                Text(
                  faq.answer,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface.withAlpha(180),
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact Option Card
// ─────────────────────────────────────────────────────────────────────────────

class _ContactOptionCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _ContactOptionCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 20,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

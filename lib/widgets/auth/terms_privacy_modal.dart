import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/legal_texts.dart';
import '../../core/theme/app_colors.dart';

/// Interactive modal sheet displaying full Terms of Service and Privacy Policy
class TermsPrivacyModal extends StatefulWidget {
  const TermsPrivacyModal({
    super.key,
    this.initialDocument = LegalDocumentType.termsOfService,
    this.onAccept,
  });

  final LegalDocumentType initialDocument;
  final VoidCallback? onAccept;

  /// Shows the legal modal bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    String? title,
    LegalDocumentType? initialDocument,
    VoidCallback? onAccept,
  }) {
    LegalDocumentType docType = initialDocument ?? LegalDocumentType.termsOfService;
    if (title != null) {
      if (title.toLowerCase().contains('privacy')) {
        docType = LegalDocumentType.privacyPolicy;
      } else {
        docType = LegalDocumentType.termsOfService;
      }
    }

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => TermsPrivacyModal(
        initialDocument: docType,
        onAccept: onAccept,
      ),
    );
  }

  @override
  State<TermsPrivacyModal> createState() => _TermsPrivacyModalState();
}

class _TermsPrivacyModalState extends State<TermsPrivacyModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialDocument == LegalDocumentType.privacyPolicy ? 1 : 0,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showToast('Could not open external browser for: $url');
      }
    } catch (_) {
      _showToast('Unable to open link');
    }
  }

  Future<void> _sendEmail() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: LegalTexts.contactEmail,
      queryParameters: {
        'subject': 'INav Inquiry / Legal Question',
      },
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await Clipboard.setData(const ClipboardData(text: LegalTexts.contactEmail));
        _showToast('Email copied to clipboard: ${LegalTexts.contactEmail}');
      }
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: LegalTexts.contactEmail));
      _showToast('Email copied: ${LegalTexts.contactEmail}');
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final surfaceBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.hairlineDark : AppColors.hairlineLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legal Documents',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: border,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${AppConstants.appName} • Indonesia',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Updated ${AppConstants.legalLastUpdatedShort}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cardBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: border),
                    ),
                    child: Icon(Icons.close, size: 18, color: textMuted),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Segmented Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor: textMuted,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Terms of Service'),
                  Tab(text: 'Privacy Policy'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Action Link Strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _MiniActionButton(
                    icon: Icons.open_in_new_rounded,
                    label: 'Live TermsFeed Policy',
                    onTap: () => _launchExternalUrl(LegalTexts.privacyPolicyUrl),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniActionButton(
                    icon: Icons.mail_outline_rounded,
                    label: 'Contact Support',
                    onTap: _sendEmail,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 20, thickness: 1),

          // Scrollable Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Terms of Service
                _LegalDocumentList(
                  documentType: LegalDocumentType.termsOfService,
                  sections: LegalTexts.termsOfServiceSections,
                  lastUpdated: LegalTexts.termsLastUpdated,
                ),

                // Tab 2: Privacy Policy
                _LegalDocumentList(
                  documentType: LegalDocumentType.privacyPolicy,
                  sections: LegalTexts.privacyPolicySections,
                  lastUpdated: LegalTexts.privacyLastUpdated,
                  liveUrl: LegalTexts.privacyPolicyUrl,
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(top: BorderSide(color: border)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  if (widget.onAccept != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: border),
                        ),
                        child: Text(
                          'Decline',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () {
                          widget.onAccept?.call();
                          Navigator.of(context).pop(true);
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'I Agree & Accept',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Done Reading',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final border = isDark ? AppColors.hairlineDark : AppColors.hairlineLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalDocumentList extends StatelessWidget {
  const _LegalDocumentList({
    required this.documentType,
    required this.sections,
    required this.lastUpdated,
    this.liveUrl,
  });

  final LegalDocumentType documentType;
  final List<LegalSection> sections;
  final String lastUpdated;
  final String? liveUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // Document Title Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    documentType == LegalDocumentType.termsOfService
                        ? Icons.description_outlined
                        : Icons.privacy_tip_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      documentType.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textMain,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Last updated: $lastUpdated',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
              if (liveUrl != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Verified Live URL: $liveUrl',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Render each section
        ...sections.map((section) => _SectionCard(section: section)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.hairlineDark : AppColors.hairlineLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    final isCallout = section.isCallout;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCallout ? primary.withValues(alpha: 0.04) : cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCallout ? primary.withValues(alpha: 0.3) : border,
          width: isCallout ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isCallout) ...[
                Icon(Icons.star_rounded, color: primary, size: 18),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  section.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isCallout ? primary : textMain,
                  ),
                ),
              ),
            ],
          ),

          if (section.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              section.subtitle!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ],

          if (section.introductoryText != null) ...[
            const SizedBox(height: 8),
            Text(
              section.introductoryText!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: textMuted,
                height: 1.5,
              ),
            ),
          ],

          // Paragraphs
          for (final p in section.paragraphs) ...[
            const SizedBox(height: 8),
            Text(
              p,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: textMain.withValues(alpha: 0.85),
                height: 1.55,
              ),
            ),
          ],

          // Bullet points
          if (section.bulletPoints.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final bullet in section.bulletPoints) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: textMain.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          // Subsections
          if (section.subSections.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final sub in section.subSections) ...[
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sub.content,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textMuted,
                        height: 1.5,
                      ),
                    ),
                    if (sub.bulletPoints.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      for (final bp in sub.bulletPoints) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6, right: 6),
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  bp,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: textMuted,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';

/// Clean, production-ready Privacy Policy sheet explaining financial data safety & compliance
class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PrivacyPolicyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const PhosphorIcon(
                        PhosphorIconsBold.shieldCheck,
                        color: Color(0xFF059669),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Policy',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutralDark,
                            ),
                          ),
                          Text(
                            'Last updated: September 2026',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const PhosphorIcon(PhosphorIconsRegular.x, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0xFFF1F5F9), height: 20),

              // Policy Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  children: [
                    _buildSection(
                      title: '1. Financial Data Protection',
                      content:
                          'MobyMoney is designed with privacy-first financial architecture. Your personal transaction records, expenses, receipts, and custom categories are stored securely using industry-standard AES encryption both in transit (TLS 1.3) and at rest.',
                    ),
                    _buildSection(
                      title: '2. Information We Collect',
                      content:
                          'We only collect information necessary to provide expense tracking services:\n• Basic account profile (Name, email address, profile photo from Google Auth)\n• Financial logs created by you (Amounts, categories, tags, timestamps, notes)\n• Device preferences such as selected currency and theme.',
                    ),
                    _buildSection(
                      title: '3. No Data Selling / Third-Party Tracking',
                      content:
                          'We do NOT sell, rent, or trade your personal financial data to advertisers, lenders, or third-party marketing companies. Your spending data is strictly yours.',
                    ),
                    _buildSection(
                      title: '4. AI Chat & Categorization Privacy',
                      content:
                          'When using AI-assisted financial insights and receipt scanning, your queries are processed through private, authenticated endpoints without being retained for third-party public AI training.',
                    ),
                    _buildSection(
                      title: '5. Account & Data Deletion Rights',
                      content:
                          'You have full ownership of your data. You may export your complete financial records to Excel (XLSX) anytime or permanently clear expense history and request account deletion via app settings.',
                    ),
                    _buildSection(
                      title: '6. Contact & Data Protection Officer',
                      content:
                          'If you have questions about privacy practices or wish to submit a data inquiry, please contact our privacy team at privacy@mobymoney.com.',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const PhosphorIcon(
                            PhosphorIconsBold.lockKey,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your financial records are encrypted and protected by MobyMoney Secure Shield.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.slate600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

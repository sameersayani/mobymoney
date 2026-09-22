import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_snack_bar.dart';
import '../providers/ai_chat_provider.dart';
import '../../domain/models/chat_message.dart';

class AiChatBubble extends ConsumerWidget {
  final ChatMessage message;
  final Function(String query)? onFollowUpSelected;

  const AiChatBubble({
    super.key,
    required this.message,
    this.onFollowUpSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (message.isUser) {
      return _buildUserBubble(context);
    } else {
      return _buildAiBubble(context, ref);
    }
  }

  Widget _buildUserBubble(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 16, top: 6, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeStr,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(width: 4),
              const PhosphorIcon(
                PhosphorIconsRegular.checks,
                size: 13,
                color: AppColors.primaryLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiBubble(BuildContext context, WidgetRef ref) {
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);
    final isFailed = message.status == MessageStatus.failed;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 28, top: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Badge Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFailed
                        ? [const Color(0xFFF57C00), const Color(0xFFEF4444)]
                        : [AppColors.primary, const Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: (isFailed ? AppColors.error : AppColors.primary)
                          .withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: PhosphorIcon(
                    isFailed
                        ? PhosphorIconsRegular.warning
                        : PhosphorIconsFill.sparkle,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Main Message Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isFailed ? const Color(0xFFFEF2F2) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(
                      color: isFailed ? const Color(0xFFFECACA) : AppColors.slate200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFailed) ...[
                        Row(
                          children: [
                            const PhosphorIcon(
                              PhosphorIconsRegular.warningCircle,
                              color: AppColors.error,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Connection Issue',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      // Formatted Text Content
                      _buildFormattedContent(message.content),

                      // AI Action Confirmation Card (If operation/arguments present)
                      if ((message.operation != null || (message.arguments != null && message.arguments!.isNotEmpty)) && !message.isConfirmed) ...[
                        const SizedBox(height: 12),
                        _buildActionConfirmationCard(context, ref),
                      ] else if (message.isConfirmed) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const PhosphorIcon(
                                PhosphorIconsFill.checkCircle,
                                size: 14,
                                color: AppColors.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Action successfully completed',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Optional Financial Highlights Card
                      if (message.highlights != null &&
                          message.highlights!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _buildFinancialHighlightsGrid(message.highlights!),
                      ],

                      const SizedBox(height: 10),

                      // Footer with timestamp & copy button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.tertiary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Moby AI • $timeStr',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.slate400,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: message.content),
                              );
                              AppSnackBar.showInfo(context, 'Response copied to clipboard');
                            },
                            child: Row(
                              children: [
                                const PhosphorIcon(
                                  PhosphorIconsRegular.copy,
                                  size: 13,
                                  color: AppColors.slate400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Copy',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Suggested Follow-up chips
          if (message.suggestedFollowUps != null &&
              message.suggestedFollowUps!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestedFollowUps!.map((query) {
                  return InkWell(
                    onTap: () => onFollowUpSelected?.call(query),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PhosphorIcon(
                            PhosphorIconsRegular.sparkle,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              query,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const PhosphorIcon(
                            PhosphorIconsRegular.arrowUpRight,
                            size: 12,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialHighlightsGrid(List<ChatFinancialHighlight> highlights) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.slate200,
          width: 1,
        ),
      ),
      child: Row(
        children: highlights.map((h) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      h.value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ),
                  if (h.trend != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          h.isPositive
                              ? PhosphorIconsRegular.trendUp
                              : PhosphorIconsRegular.trendDown,
                          size: 12,
                          color: h.isPositive
                              ? AppColors.tertiary
                              : AppColors.error,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              h.trend!,
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: h.isPositive
                                    ? AppColors.tertiary
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    // Simple inline parser for markdown bolding (**bold**) and bullet points
    final lines = content.split('\n');
    List<Widget> lineWidgets = [];

    for (var line in lines) {
      if (line.isEmpty) {
        lineWidgets.add(const SizedBox(height: 6));
        continue;
      }

      lineWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: _buildRichTextLine(line),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lineWidgets,
    );
  }

  Widget _buildRichTextLine(String text) {
    final parts = text.split('**');
    List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      final isBold = i % 2 == 1;

      spans.add(
        TextSpan(
          text: parts[i],
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? AppColors.neutralDark : AppColors.slate700,
            height: 1.45,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildActionConfirmationCard(BuildContext context, WidgetRef ref) {
    final isDelete = (message.operation?.toLowerCase().contains('delete') ?? false) ||
        (message.content.toLowerCase().contains('delete') && message.arguments != null);
    final opName = message.operation ?? (isDelete ? 'Delete' : 'Confirm Action');
    final chatState = ref.watch(aiChatProvider);
    final isExecuting = chatState.isExecutingAction;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDelete
            ? AppColors.errorContainer.withValues(alpha: 0.5)
            : AppColors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDelete
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                isDelete ? PhosphorIconsFill.trash : PhosphorIconsFill.lightning,
                size: 16,
                color: isDelete ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Proposed Action: $opName',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDelete ? AppColors.error : AppColors.onPrimaryContainer,
                ),
              ),
            ],
          ),
          if (message.arguments != null && message.arguments!.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...message.arguments!.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '• ${e.key}: ${e.value}',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate700,
                  ),
                ),
              );
            }),
          ],
          if (message.reallyNeeded != null) ...[
            const SizedBox(height: 4),
            Text(
              'Tag: ${message.reallyNeeded == true ? "Essential (Needed)" : "Discretionary (Not Needed)"}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: message.reallyNeeded == true ? AppColors.tertiary : AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: isExecuting
                  ? null
                  : () async {
                      bool success = false;
                      if (isDelete) {
                        success = await ref.read(aiChatProvider.notifier).confirmAiDelete(message);
                      } else {
                        success = await ref.read(aiChatProvider.notifier).confirmAiClassification(message);
                      }

                      if (context.mounted) {
                        if (success) {
                          AppSnackBar.showSuccess(context, 'Action executed successfully!');
                        } else {
                          AppSnackBar.showError(
                            context,
                            ref.read(aiChatProvider).errorMessage ?? 'Failed to execute action',
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDelete ? AppColors.error : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: isExecuting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const PhosphorIcon(PhosphorIconsRegular.check, size: 16),
              label: Text(
                isExecuting ? 'Executing...' : 'Confirm & Execute',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

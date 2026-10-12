import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/constants/app_currency.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_snack_bar.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';
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

  // ─── User Bubble ────────────────────────────────────────────────────────────

  Widget _buildUserBubble(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 16, top: 6, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(5),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 5),
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

  // ─── AI Bubble ───────────────────────────────────────────────────────────────

  Widget _buildAiBubble(BuildContext context, WidgetRef ref) {
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);
    final isFailed = message.status == MessageStatus.failed;
    final hasAction = (message.operation != null ||
            (message.arguments != null && message.arguments!.isNotEmpty)) &&
        !message.isConfirmed;

    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 24, top: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── AI Avatar ─────────────────────────────────────────────────
              _AiAvatar(isFailed: isFailed),
              const SizedBox(width: 10),

              // ─── Message Card ───────────────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isFailed
                        ? const Color(0xFFFFF5F5)
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: isFailed
                          ? AppColors.error.withValues(alpha: 0.25)
                          : AppColors.slate200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Top gradient accent bar ──────────────────────────
                      if (!isFailed)
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.7),
                                AppColors.primaryLight.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(20),
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Error Header ───────────────────────────────
                            if (isFailed) ...[
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const PhosphorIcon(
                                      PhosphorIconsRegular.warningCircle,
                                      color: AppColors.error,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                              const SizedBox(height: 8),
                            ],

                            // ─── Formatted Markdown Content ─────────────────
                            _buildMarkdownContent(message.content),

                            // ─── Action Confirmation Card ───────────────────
                            if (hasAction) ...[
                              const SizedBox(height: 14),
                              _buildActionConfirmationCard(context, ref),
                            ] else if (message.isConfirmed) ...[
                              const SizedBox(height: 10),
                              _buildConfirmedBadge(),
                            ],

                            // ─── Financial Highlights ───────────────────────
                            if (message.highlights != null &&
                                message.highlights!.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              _buildFinancialHighlightsGrid(message.highlights!),
                            ],

                            const SizedBox(height: 10),

                            // ─── Footer ─────────────────────────────────────
                            _buildFooter(context, timeStr),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ─── Follow-up Chips ────────────────────────────────────────────────
          if (message.suggestedFollowUps != null &&
              message.suggestedFollowUps!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestedFollowUps!.map((query) {
                  return _FollowUpChip(
                    query: query,
                    onTap: () => onFollowUpSelected?.call(query),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tertiary.withValues(alpha: 0.12),
            AppColors.primaryLight.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PhosphorIcon(
            PhosphorIconsFill.checkCircle,
            size: 14,
            color: AppColors.tertiary,
          ),
          const SizedBox(width: 7),
          Text(
            'Action completed successfully',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, String timeStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Smart AI • $timeStr',
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
            Clipboard.setData(ClipboardData(text: message.content));
            AppSnackBar.showInfo(context, 'Response copied to clipboard');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const PhosphorIcon(
                  PhosphorIconsRegular.copy,
                  size: 11,
                  color: AppColors.slate500,
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
        ),
      ],
    );
  }

  // ─── Markdown Content Renderer ───────────────────────────────────────────────

  Widget _buildMarkdownContent(String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];
    int i = 0;

    while (i < lines.length) {
      final line = lines[i];

      // Blank line
      if (line.trim().isEmpty) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 4));
        i++;
        continue;
      }

      // H1 — # Title
      if (line.startsWith('# ') && !line.startsWith('## ')) {
        widgets.add(_MdHeading(text: line.substring(2), level: 1));
        i++;
        continue;
      }

      // H2 — ## Title
      if (line.startsWith('## ') && !line.startsWith('### ')) {
        widgets.add(_MdHeading(text: line.substring(3), level: 2));
        i++;
        continue;
      }

      // H3 — ### Title
      if (line.startsWith('### ')) {
        widgets.add(_MdHeading(text: line.substring(4), level: 3));
        i++;
        continue;
      }

      // Horizontal rule ---
      if (RegExp(r'^[-*_]{3,}$').hasMatch(line.trim())) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(
            color: AppColors.slate200,
            thickness: 1,
            height: 1,
          ),
        ));
        i++;
        continue;
      }

      // Unordered bullet — - item or * item
      if (line.startsWith('- ') || line.startsWith('* ')) {
        final bulletText = line.startsWith('- ')
            ? line.substring(2)
            : line.substring(2);
        widgets.add(_MdBulletItem(text: bulletText));
        i++;
        continue;
      }

      // Numbered list — 1. item
      final numberedMatch = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line);
      if (numberedMatch != null) {
        final num = numberedMatch.group(1)!;
        final text = numberedMatch.group(2)!;
        widgets.add(_MdNumberedItem(number: num, text: text));
        i++;
        continue;
      }

      // Blockquote — > text
      if (line.startsWith('> ')) {
        widgets.add(_MdBlockquote(text: line.substring(2)));
        i++;
        continue;
      }

      // Code block — ```
      if (line.trim().startsWith('```')) {
        final codeLines = <String>[];
        i++; // skip opening ```
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        i++; // skip closing ```
        widgets.add(_MdCodeBlock(code: codeLines.join('\n')));
        continue;
      }

      // Normal paragraph line
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: _buildInlineRichText(line),
        ),
      );
      i++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Parses inline markdown: **bold**, *italic*, `code`, and plain text
  Widget _buildInlineRichText(String text) {
    final spans = _parseInlineMarkdown(text);
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  List<TextSpan> _parseInlineMarkdown(String text) {
    final spans = <TextSpan>[];
    final baseStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.slate700,
      height: 1.55,
    );

    // We match: **bold**, *italic*, `code`, or plain text in order
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      if (match.group(1) != null) {
        // **bold**
        spans.add(TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutralDark,
          ),
        ));
      } else if (match.group(2) != null) {
        // *italic*
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: AppColors.slate600,
          ),
        ));
      } else if (match.group(3) != null) {
        // `code`
        spans.add(TextSpan(
          text: ' ${match.group(3)} ',
          style: GoogleFonts.robotoMono(
            fontSize: 12.5,
            color: AppColors.primary,
            backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.4),
          ),
        ));
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return spans.isEmpty
        ? [TextSpan(text: text, style: baseStyle)]
        : spans;
  }

  // ─── Financial Highlights ────────────────────────────────────────────────────

  Widget _buildFinancialHighlightsGrid(
      List<ChatFinancialHighlight> highlights) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.slate50,
            AppColors.primaryContainer.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      child: Row(
        children: highlights.map((h) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.label,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      h.value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ),
                  if (h.trend != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          h.isPositive
                              ? PhosphorIconsRegular.trendUp
                              : PhosphorIconsRegular.trendDown,
                          size: 11,
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

  // ─── Action Confirmation Card ────────────────────────────────────────────────

  Widget _buildActionConfirmationCard(BuildContext context, WidgetRef ref) {
    final isDelete =
        (message.operation?.toLowerCase().contains('delete') ?? false) ||
            (message.content.toLowerCase().contains('delete') &&
                message.arguments != null);
    final chatState = ref.watch(aiChatProvider);
    final isExecuting = chatState.isExecutingAction;
    final currency = ref.watch(currencyProvider);

    final accentColor = isDelete ? AppColors.error : AppColors.primary;
    final isReallyNeeded = message.reallyNeeded ?? false;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDelete
              ? AppColors.error.withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDelete ? AppColors.error : AppColors.primary)
                .withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 1. Header with Badge ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDelete
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDFA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: (isDelete ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDelete
                          ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                          : [const Color(0xFF0F766E), const Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: (isDelete ? AppColors.error : AppColors.primary)
                            .withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: PhosphorIcon(
                      isDelete
                          ? PhosphorIconsFill.trash
                          : PhosphorIconsFill.lightning,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDelete ? 'EXPENSE DELETION' : 'SMART PROPOSAL',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        message.operation ??
                            (isDelete ? 'Delete Record' : 'Log Expense'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutralDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Review',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── 2. Structured Data / Key-Value Preview ─────────────────────────
          if (message.arguments != null && message.arguments!.isNotEmpty)
            _buildStructuredArgumentsView(
              message.arguments!,
              currency.symbol,
              accentColor,
            ),

          // ─── 3. AI Suggestion & Necessity Analysis ──────────────────────────
          if (message.reallyNeeded != null ||
              (message.reason != null && message.reason!.isNotEmpty))
            _buildNecessityAssessmentCard(isReallyNeeded, message.reason),

          // ─── 4. Action Buttons ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: isDelete
                ? _buildDeleteActionButtons(context, ref, isExecuting)
                : _buildClassificationActionButtons(
                    context, ref, isExecuting, isReallyNeeded),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredArgumentsView(
    Map<String, dynamic> args,
    String currencySymbol,
    Color accentColor,
  ) {
    dynamic amountVal;
    String? categoryVal;
    String? paymentMethodVal;
    String? dateVal;
    String? descriptionVal;
    String? currencyCodeVal;
    final otherArgs = <String, dynamic>{};

    for (final entry in args.entries) {
      final k = entry.key.toLowerCase();
      if (k == 'currency' || k == 'currency_code' || k == 'currencycode') {
        currencyCodeVal = entry.value?.toString();
      } else if (k.contains('amount') || k == 'price' || k == 'cost') {
        amountVal = entry.value;
      } else if (k.contains('category') || k.contains('type') || k == 'expense_type') {
        categoryVal = entry.value?.toString();
      } else if (k.contains('payment') || k.contains('method') || k == 'mode' || k == 'paid_via') {
        paymentMethodVal = entry.value?.toString();
      } else if (k.contains('date') || k == 'time') {
        dateVal = entry.value?.toString();
      } else if (k.contains('description') || k.contains('note') || k == 'title' || k == 'remarks') {
        descriptionVal = entry.value?.toString();
      } else {
        otherArgs[entry.key] = entry.value;
      }
    }

    final activeSymbol = currencyCodeVal != null
        ? AppCurrency.fromCode(currencyCodeVal).symbol
        : currencySymbol;

    String formattedAmount = '';
    if (amountVal != null) {
      if (amountVal is num) {
        formattedAmount = '$activeSymbol${NumberFormat('#,##,###.##').format(amountVal)}';
      } else {
        formattedAmount = '$activeSymbol$amountVal';
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Amount Banner (if present)
          if (formattedAmount.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.slate100.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate500,
                    ),
                  ),
                  Text(
                    formattedAmount,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutralDark,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),

          // Metadata Chips / Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (categoryVal != null && categoryVal.isNotEmpty)
                _buildDataChip(
                  icon: PhosphorIconsRegular.tag,
                  label: 'Category',
                  value: categoryVal,
                  bgColor: const Color(0xFFF0FDF4),
                  textColor: const Color(0xFF166534),
                  borderColor: const Color(0xFFBBF7D0),
                ),
              if (paymentMethodVal != null && paymentMethodVal.isNotEmpty)
                _buildDataChip(
                  icon: PhosphorIconsRegular.creditCard,
                  label: 'Payment',
                  value: paymentMethodVal,
                  bgColor: const Color(0xFFF0F9FF),
                  textColor: const Color(0xFF075985),
                  borderColor: const Color(0xFFBAE6FD),
                ),
              if (dateVal != null && dateVal.isNotEmpty)
                _buildDataChip(
                  icon: PhosphorIconsRegular.calendarBlank,
                  label: 'Date',
                  value: dateVal,
                  bgColor: const Color(0xFFF8FAFC),
                  textColor: const Color(0xFF334155),
                  borderColor: const Color(0xFFE2E8F0),
                ),
              if (descriptionVal != null && descriptionVal.isNotEmpty)
                _buildDataChip(
                  icon: PhosphorIconsRegular.notepad,
                  label: 'Note',
                  value: descriptionVal,
                  bgColor: const Color(0xFFFAF5FF),
                  textColor: const Color(0xFF6B21A8),
                  borderColor: const Color(0xFFE9D5FF),
                ),
              ...otherArgs.entries.map((e) {
                final k = e.key.replaceAll('_', ' ');
                final title = k.isNotEmpty
                    ? '${k[0].toUpperCase()}${k.substring(1)}'
                    : k;
                return _buildDataChip(
                  icon: PhosphorIconsRegular.circle,
                  label: title,
                  value: '${e.value}',
                  bgColor: const Color(0xFFF8FAFC),
                  textColor: const Color(0xFF475569),
                  borderColor: const Color(0xFFE2E8F0),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataChip({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNecessityAssessmentCard(bool isReallyNeeded, String? reason) {
    final bgColor = isReallyNeeded ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB);
    final borderColor = isReallyNeeded ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D);
    final textColor = isReallyNeeded ? const Color(0xFF166534) : const Color(0xFF92400E);
    final badgeBg = isReallyNeeded ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PhosphorIcon(
                      isReallyNeeded
                          ? PhosphorIconsFill.shieldCheck
                          : PhosphorIconsFill.sparkle,
                      size: 13,
                      color: textColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isReallyNeeded
                          ? 'ESSENTIAL NEED'
                          : 'DISCRETIONARY SPEND',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhosphorIcon(
                  PhosphorIconsRegular.quotes,
                  size: 14,
                  color: textColor.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    reason,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColor.withValues(alpha: 0.95),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClassificationActionButtons(
    BuildContext context,
    WidgetRef ref,
    bool isExecuting,
    bool isReallyNeeded,
  ) {
    return Column(
      children: [
        // 1. Primary Save Button (Full Width, Gradient, Glowing)
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: isExecuting
                ? null
                : () async {
                    final success = await ref
                        .read(aiChatProvider.notifier)
                        .confirmAiClassification(message);
                    if (context.mounted) {
                      if (success) {
                        AppSnackBar.showSuccess(context, 'Expense saved successfully!');
                      } else {
                        AppSnackBar.showError(
                          context,
                          ref.read(aiChatProvider).errorMessage ??
                              'Failed to save expense',
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: isExecuting
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Container(
                alignment: Alignment.center,
                child: isExecuting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const PhosphorIcon(
                            PhosphorIconsBold.checkCircle,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Confirm & Save Expense',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 2. Secondary Actions Row (Toggle Needed / Cancel)
        Row(
          children: [
            // Toggle Needed / Not Needed Button
            Expanded(
              child: OutlinedButton(
                onPressed: isExecuting
                    ? null
                    : () async {
                        final currentNeeded = message.reallyNeeded ?? false;
                        final success = await ref
                            .read(aiChatProvider.notifier)
                            .confirmAiClassification(
                              message,
                              overrideReallyNeeded: !currentNeeded,
                            );
                        if (context.mounted) {
                          if (success) {
                            AppSnackBar.showSuccess(context, 'Expense saved!');
                          } else {
                            AppSnackBar.showError(
                              context,
                              ref.read(aiChatProvider).errorMessage ??
                                  'Failed to save expense',
                            );
                          }
                        }
                      },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isReallyNeeded
                      ? const Color(0xFFFFFBEB)
                      : const Color(0xFFF0FDF4),
                  foregroundColor: isReallyNeeded
                      ? const Color(0xFF92400E)
                      : const Color(0xFF166534),
                  side: BorderSide(
                    color: isReallyNeeded
                        ? const Color(0xFFFCD34D)
                        : const Color(0xFF86EFAC),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PhosphorIcon(
                      isReallyNeeded
                          ? PhosphorIconsRegular.sparkle
                          : PhosphorIconsRegular.shieldCheck,
                      size: 14,
                      color: isReallyNeeded
                          ? const Color(0xFFD97706)
                          : const Color(0xFF059669),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        isReallyNeeded ? 'Save as Not Needed' : 'Save as Needed',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isReallyNeeded
                              ? const Color(0xFF92400E)
                              : const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Dismiss Button
            SizedBox(
              height: 38,
              child: OutlinedButton(
                onPressed: isExecuting
                    ? null
                    : () => ref.read(aiChatProvider.notifier).denyAction(message),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.slate50,
                  foregroundColor: AppColors.slate600,
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PhosphorIcon(
                      PhosphorIconsRegular.x,
                      size: 13,
                      color: AppColors.slate500,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Dismiss',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeleteActionButtons(
    BuildContext context,
    WidgetRef ref,
    bool isExecuting,
  ) {
    return Row(
      children: [
        // Cancel
        Expanded(
          child: OutlinedButton(
            onPressed: isExecuting
                ? null
                : () => ref.read(aiChatProvider.notifier).denyAction(message),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.slate600,
              side: const BorderSide(color: AppColors.slate300, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Confirm Delete
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: isExecuting
                ? null
                : () async {
                    final success = await ref
                        .read(aiChatProvider.notifier)
                        .confirmAiDelete(message);
                    if (context.mounted) {
                      if (success) {
                        AppSnackBar.showSuccess(context, 'Expense deleted!');
                      } else {
                        AppSnackBar.showError(
                          context,
                          ref.read(aiChatProvider).errorMessage ??
                              'Failed to delete expense',
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
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
                : const PhosphorIcon(PhosphorIconsRegular.trash, size: 15),
            label: Text(
              isExecuting ? 'Deleting...' : 'Confirm Delete',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Sub-Widgets ──────────────────────────────────────────────────────────────

class _AiAvatar extends StatelessWidget {
  final bool isFailed;
  const _AiAvatar({required this.isFailed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFailed
              ? [const Color(0xFFF87171), const Color(0xFFEF4444)]
              : [const Color(0xFF0F766E), const Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: (isFailed ? AppColors.error : AppColors.primary)
                .withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: PhosphorIcon(
          isFailed ? PhosphorIconsRegular.warning : PhosphorIconsFill.sparkle,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _FollowUpChip extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  const _FollowUpChip({required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
            const SizedBox(width: 5),
            const PhosphorIcon(
              PhosphorIconsRegular.arrowUpRight,
              size: 11,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Markdown Element Widgets ─────────────────────────────────────────────────

class _MdHeading extends StatelessWidget {
  final String text;
  final int level;
  const _MdHeading({required this.text, required this.level});

  @override
  Widget build(BuildContext context) {
    final fontSize = level == 1 ? 17.0 : level == 2 ? 15.5 : 14.0;
    final bottomPad = level == 1 ? 10.0 : level == 2 ? 8.0 : 6.0;
    final topPad = level == 1 ? 4.0 : 2.0;

    return Padding(
      padding: EdgeInsets.only(top: topPad, bottom: bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.neutralDark,
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),
          if (level == 1 || level == 2) ...[
            const SizedBox(height: 4),
            Container(
              height: level == 1 ? 2 : 1,
              width: level == 1 ? 32 : 20,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: level == 1 ? 0.6 : 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MdBulletItem extends StatelessWidget {
  final String text;
  const _MdBulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: _InlineRichText(text: text),
          ),
        ],
      ),
    );
  }
}

class _MdNumberedItem extends StatelessWidget {
  final String number;
  final String text;
  const _MdNumberedItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Expanded(
            child: _InlineRichText(text: text),
          ),
        ],
      ),
    );
  }
}

class _MdBlockquote extends StatelessWidget {
  final String text;
  const _MdBlockquote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.25),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: const Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: _InlineRichText(
        text: text,
        style: GoogleFonts.inter(
          fontSize: 13.5,
          fontStyle: FontStyle.italic,
          color: AppColors.slate600,
          height: 1.5,
        ),
      ),
    );
  }
}

class _MdCodeBlock extends StatelessWidget {
  final String code;
  const _MdCodeBlock({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.slate700.withValues(alpha: 0.6),
        ),
      ),
      child: Text(
        code,
        style: GoogleFonts.robotoMono(
          fontSize: 12,
          color: const Color(0xFF86EFAC), // soft green
          height: 1.5,
        ),
      ),
    );
  }
}

/// A helper widget that renders inline markdown (bold, italic, code) in a RichText.
class _InlineRichText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const _InlineRichText({required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ??
        GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.slate700,
          height: 1.55,
        );

    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      if (match.group(1) != null) {
        spans.add(TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutralDark,
            fontStyle: FontStyle.normal,
          ),
        ));
      } else if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: AppColors.slate600,
          ),
        ));
      } else if (match.group(3) != null) {
        spans.add(TextSpan(
          text: ' ${match.group(3)} ',
          style: GoogleFonts.robotoMono(
            fontSize: 12.5,
            color: AppColors.primary,
            backgroundColor:
                AppColors.primaryContainer.withValues(alpha: 0.4),
          ),
        ));
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(
        children: spans.isEmpty
            ? [TextSpan(text: text, style: baseStyle)]
            : spans,
      ),
    );
  }
}

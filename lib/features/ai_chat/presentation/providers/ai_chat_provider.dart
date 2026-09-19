import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/chat_message.dart';

class AiChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  const AiChatState({
    this.messages = const [],
    this.isTyping = false,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    return AiChatState(
      messages: [
        ChatMessage(
          id: 'welcome-1',
          content:
              'Hello Alex! 👋 I\'m **Moby AI**, your personal financial co-pilot.\n\nI can help you understand your spending, find savings opportunities, organize budgets, or analyze your monthly transactions.\n\nHow can I help you today?',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          highlights: const [
            ChatFinancialHighlight(
              label: 'Monthly Spend',
              value: '₹34,820',
              trend: '-8.4%',
              isPositive: true,
            ),
            ChatFinancialHighlight(
              label: 'Savings Goal',
              value: '68% Met',
              trend: '+5%',
              isPositive: true,
            ),
          ],
          suggestedFollowUps: const [
            'Break down my dining expenses',
            'How can I save ₹5,000 this month?',
            'Show my top spending categories',
          ],
        ),
      ],
      isTyping: false,
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMessage = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      content: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
    );

    // Simulate AI thinking and generating response
    await Future.delayed(const Duration(milliseconds: 1200));

    final aiResponse = _generateAiResponse(trimmed);

    state = state.copyWith(
      messages: [...state.messages, aiResponse],
      isTyping: false,
    );
  }

  void clearChat() {
    state = const AiChatState(messages: [], isTyping: false);
  }

  void resetToDefault() {
    state = build();
  }

  ChatMessage _generateAiResponse(String query) {
    final q = query.toLowerCase();
    final id = 'ai-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    if (q.contains('dining') || q.contains('food') || q.contains('restaurant') || q.contains('swiggy') || q.contains('zomato')) {
      return ChatMessage(
        id: id,
        content:
            'Here is a breakdown of your **Food & Dining** expenses for this month:\n\n'
            '• **Total Spent:** ₹8,450 across 18 transactions\n'
            '• **Top Merchant:** Swiggy (₹3,820 / 8 orders)\n'
            '• **Dining Out:** ₹3,200 (Weekends)\n'
            '• **Average Daily Cost:** ₹281\n\n'
            '💡 **Insight:** You are currently spending **24% of your total budget** on dining. Cooking at home just 2 extra nights a week could save approximately **₹2,400/month**.',
        isUser: false,
        timestamp: now,
        highlights: const [
          ChatFinancialHighlight(
            label: 'Dining Spend',
            value: '₹8,450',
            trend: '+14% vs last mo',
            isPositive: false,
          ),
          ChatFinancialHighlight(
            label: 'Potential Savings',
            value: '₹2,400',
            trend: 'High Impact',
            isPositive: true,
          ),
        ],
        suggestedFollowUps: const [
          'Set dining budget to ₹6,000',
          'Compare to last month',
          'Audit recurring food subscriptions',
        ],
      );
    } else if (q.contains('save') || q.contains('saving') || q.contains('5000') || q.contains('5,000')) {
      return ChatMessage(
        id: id,
        content:
            'Here is an actionable **₹5,000 Monthly Savings Blueprint** based on your recent activity:\n\n'
            '1. **Optimize Subscriptions (Save ~₹1,200):**\n'
            '   You have 2 overlapping OTT plans (Netflix & Disney+ Hotstar) with low usage this month.\n\n'
            '2. **Trim Weekend Food Delivery (Save ~₹2,500):**\n'
            '   Swiggy deliveries on Friday/Saturday averaged ₹650 per order. Replacing 4 orders with home meals saves ₹2,500.\n\n'
            '3. **Cab vs Public Transit (Save ~₹1,500):**\n'
            '   Uber/Ola micro-trips under 3km cost ₹1,800 this month.\n\n'
            '✨ **Projected Annual Impact:** Saving ₹5,000/mo puts **₹60,000** into your emergency fund or index portfolio!',
        isUser: false,
        timestamp: now,
        highlights: const [
          ChatFinancialHighlight(
            label: 'Identified Savings',
            value: '₹5,200/mo',
            trend: '+100% Target',
            isPositive: true,
          ),
          ChatFinancialHighlight(
            label: 'Annual Growth',
            value: '₹62,400',
            trend: 'At 8% ROI',
            isPositive: true,
          ),
        ],
        suggestedFollowUps: const [
          'Create Auto-Save Rule',
          'Show inactive subscriptions',
          'Review utility bills',
        ],
      );
    } else if (q.contains('category') || q.contains('categories') || q.contains('breakdown') || q.contains('spend') || q.contains('spending')) {
      return ChatMessage(
        id: id,
        content:
            'Here is the category-wise distribution of your **₹34,820 total spend**:\n\n'
            '1. 🏠 **Housing & Utilities:** ₹14,200 (40.8%)\n'
            '2. 🍔 **Food & Groceries:** ₹9,150 (26.3%)\n'
            '3. 🚗 **Transportation:** ₹4,320 (12.4%)\n'
            '4. 🎬 **Entertainment & Subs:** ₹3,850 (11.0%)\n'
            '5. 🛍️ **Shopping & Misc:** ₹3,300 (9.5%)\n\n'
            '✅ You are currently on track to stay within your **₹45,000 overall limit** for this billing cycle.',
        isUser: false,
        timestamp: now,
        highlights: const [
          ChatFinancialHighlight(
            label: 'Budget Used',
            value: '77.3%',
            trend: 'Healthy',
            isPositive: true,
          ),
          ChatFinancialHighlight(
            label: 'Remaining',
            value: '₹10,180',
            trend: '11 days left',
            isPositive: true,
          ),
        ],
        suggestedFollowUps: const [
          'Forecast end-of-month spend',
          'Detailed shopping review',
          'Export monthly summary',
        ],
      );
    } else if (q.contains('budget') || q.contains('limit') || q.contains('set')) {
      return ChatMessage(
        id: id,
        content:
            'I can help you configure your budget rules! 🎯\n\n'
            'Recommended monthly allocations based on the **50/30/20 Rule**:\n'
            '• **Needs (50%):** ₹25,000 (Rent, Groceries, Utilities)\n'
            '• **Wants (30%):** ₹15,000 (Dining, Gadgets, Outings)\n'
            '• **Savings & Investments (20%):** ₹10,000 (Emergency Fund & SIPs)\n\n'
            'Would you like me to enable smart notifications when any category crosses 80% of its allocation?',
        isUser: false,
        timestamp: now,
        suggestedFollowUps: const [
          'Enable 80% Threshold Alert',
          'Adjust to 60/20/20 Rule',
          'Lock discretionary spending',
        ],
      );
    } else {
      return ChatMessage(
        id: id,
        content:
            'I\'ve analyzed your inquiry regarding **"$query"**.\n\n'
            'Based on your connected accounts and transaction patterns:\n'
            '• Your financial health index is **Strong (84/100)**.\n'
            '• Cash flow remains positive with **+₹14,200 net surplus** projected for this month.\n'
            '• No unusual charges or recurring price hikes were detected in the last 7 days.\n\n'
            'Feel free to ask me for specific category deep dives, merchant comparisons, or savings strategies!',
        isUser: false,
        timestamp: now,
        suggestedFollowUps: const [
          'Check upcoming recurring bills',
          'Analyze monthly spend',
          'Show savings recommendations',
        ],
      );
    }
  }
}

final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(() {
  return AiChatNotifier();
});

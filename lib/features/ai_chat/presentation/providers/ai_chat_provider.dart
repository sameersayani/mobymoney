import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/ai_repository.dart';
import '../../domain/models/chat_message.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository();
});

class AiChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? errorMessage;
  final bool isExecutingAction;

  const AiChatState({
    this.messages = const [],
    this.isTyping = false,
    this.errorMessage,
    this.isExecutingAction = false,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? errorMessage,
    bool? isExecutingAction,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      errorMessage: errorMessage,
      isExecutingAction: isExecutingAction ?? this.isExecutingAction,
    );
  }
}

class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    return const AiChatState(
      messages: [],
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

    // Build payload messages history
    final updatedMessages = [...state.messages, userMessage];

    state = state.copyWith(
      messages: updatedMessages,
      isTyping: true,
      errorMessage: null,
    );

    try {
      final repo = ref.read(aiRepositoryProvider);

      // Convert conversation history into API format
      final apiMessages = updatedMessages.map((m) {
        return {
          'role': m.isUser ? 'user' : 'assistant',
          'content': m.content,
        };
      }).toList();

      final response = await repo.sendChatMessage(apiMessages);

      final aiMessage = ChatMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        content: response.content.isNotEmpty
            ? response.content
            : 'I processed your request.',
        isUser: false,
        timestamp: DateTime.now(),
        operation: response.operation,
        arguments: response.arguments,
        reallyNeeded: response.reallyNeeded,
        reason: response.reason,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isTyping: false,
      );
    } catch (e) {
      String cleanErr = e.toString()
          .replaceFirst(RegExp(r'^Exception:\s*'), '')
          .replaceFirst(RegExp(r'^NetworkException:\s*'), '');
      
      final fallbackAiMessage = ChatMessage(
        id: 'err-${DateTime.now().millisecondsSinceEpoch}',
        content: cleanErr,
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.failed,
      );

      state = state.copyWith(
        messages: [...state.messages, fallbackAiMessage],
        isTyping: false,
        errorMessage: cleanErr,
      );
    }
  }

  /// Confirm and execute an AI-suggested classification or operation
  Future<bool> confirmAiClassification(
    ChatMessage message, {
    bool? overrideReallyNeeded,
  }) async {
    if (message.operation == null || message.arguments == null) return false;

    state = state.copyWith(isExecutingAction: true);
    try {
      final repo = ref.read(aiRepositoryProvider);
      final finalReallyNeeded =
          overrideReallyNeeded ?? message.reallyNeeded ?? false;

      final res = await repo.confirmAiClassification(
        operation: message.operation!,
        arguments: message.arguments!,
        reallyNeeded: finalReallyNeeded,
        reason: message.reason,
      );

      String confirmReply = 'Expense saved';
      if (res is Map && res['message'] is String) {
        confirmReply = res['message'];
      }

      // Mark original message as confirmed
      final updatedMessages = state.messages.map((m) {
        if (m.id == message.id) {
          return m.copyWith(isConfirmed: true);
        }
        return m;
      }).toList();

      // Add a success confirmation assistant message
      final confirmAiMsg = ChatMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        content: confirmReply,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Refresh dashboard and expenses summary providers
      try {
        await ref.read(dashboardSummaryProvider.notifier).refresh();
        ref.invalidate(expensesSummaryProvider);
      } catch (_) {}

      state = state.copyWith(
        messages: [...updatedMessages, confirmAiMsg],
        isExecutingAction: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isExecutingAction: false,
        errorMessage: 'Failed to confirm action: ${e.toString()}',
      );
      return false;
    }
  }

  /// Confirm and execute an AI-suggested deletion
  Future<bool> confirmAiDelete(ChatMessage message) async {
    state = state.copyWith(isExecutingAction: true);
    try {
      final repo = ref.read(aiRepositoryProvider);
      await repo.confirmAiDelete(message.arguments ?? {});

      final updatedMessages = state.messages.map((m) {
        if (m.id == message.id) {
          return m.copyWith(isConfirmed: true);
        }
        return m;
      }).toList();

      // Refresh dashboard data
      await ref.read(dashboardSummaryProvider.notifier).refresh();

      state = state.copyWith(
        messages: updatedMessages,
        isExecutingAction: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isExecutingAction: false,
        errorMessage: 'Failed to confirm delete: ${e.toString()}',
      );
      return false;
    }
  }

  /// Deny (dismiss) an AI-proposed action without executing it
  void denyAction(ChatMessage message) {
    final updatedMessages = state.messages.map((m) {
      if (m.id == message.id) {
        return m.copyWith(isConfirmed: true);
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updatedMessages);
  }

  void clearChat() {
    state = const AiChatState(messages: [], isTyping: false);
  }
}

final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(() {
  return AiChatNotifier();
});

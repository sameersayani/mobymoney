import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobymoney/core/routing/app_router.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/dashboard_header_app_bar.dart';
import 'providers/ai_chat_provider.dart';
import 'widgets/ai_chat_bubble.dart';
import 'widgets/ai_chat_input.dart';
import 'widgets/ai_typing_indicator.dart';
import 'widgets/ai_welcome_view.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _handleSendMessage(String text) {
    ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final chatState = ref.watch(aiChatProvider);

    ref.listen<AiChatState>(aiChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isTyping != next.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DashboardHeaderAppBar(
        user: user,
        subtitle: 'AI HUB',
        onAvatarTap: () {
          context.push(AppRoutes.settings);
        },
      ),
      body: Column(
        children: [
          // Chat Stream or Welcome Hero
          Expanded(
            child: chatState.messages.isEmpty
                ? AiWelcomeView(
                    onSelectPrompt: (prompt) => _handleSendMessage(prompt),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < chatState.messages.length) {
                        final msg = chatState.messages[index];
                        return AiChatBubble(
                          message: msg,
                          onFollowUpSelected: (followUp) {
                            _handleSendMessage(followUp);
                          },
                        );
                      } else {
                        return const AiTypingIndicator();
                      }
                    },
                  ),
          ),

          // Bottom Input Bar
          AiChatInput(
            onSend: _handleSendMessage,
            isTyping: chatState.isTyping,
          ),
        ],
      ),
    );
  }
}

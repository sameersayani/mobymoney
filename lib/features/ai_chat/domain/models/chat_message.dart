import 'package:flutter/foundation.dart';

@immutable
class ChatFinancialHighlight {
  final String label;
  final String value;
  final String? trend; // e.g. "+12%", "-5%"
  final bool isPositive;

  const ChatFinancialHighlight({
    required this.label,
    required this.value,
    this.trend,
    this.isPositive = true,
  });
}

enum MessageStatus { sending, delivered, failed }

@immutable
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;
  final List<ChatFinancialHighlight>? highlights;
  final List<String>? suggestedFollowUps;
  final String? operation;
  final Map<String, dynamic>? arguments;
  final bool? reallyNeeded;
  final bool isConfirmed;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.delivered,
    this.highlights,
    this.suggestedFollowUps,
    this.operation,
    this.arguments,
    this.reallyNeeded,
    this.isConfirmed = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
    List<ChatFinancialHighlight>? highlights,
    List<String>? suggestedFollowUps,
    String? operation,
    Map<String, dynamic>? arguments,
    bool? reallyNeeded,
    bool? isConfirmed,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      highlights: highlights ?? this.highlights,
      suggestedFollowUps: suggestedFollowUps ?? this.suggestedFollowUps,
      operation: operation ?? this.operation,
      arguments: arguments ?? this.arguments,
      reallyNeeded: reallyNeeded ?? this.reallyNeeded,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

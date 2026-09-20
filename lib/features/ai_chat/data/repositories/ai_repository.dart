import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/errors/network_exception.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_endpoints.dart';

class AiRepository {
  AiRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  /// POST /api/ai/chat
  /// Request body: { "messages": [ { "role": "user", "content": "..." } ] }
  /// Response: String or JSON object/string
  Future<AiChatApiResponse> sendChatMessage(List<Map<String, String>> messages) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.aiChat,
        data: {
          'messages': messages,
        },
      );

      final data = response.data;
      return AiChatApiResponse.parse(data);
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to connect to AI copilot: ${e.toString()}',
      );
    }
  }

  /// POST /api/ai/confirm-delete
  /// Confirms deletion action analyzed by AI
  Future<dynamic> confirmAiDelete(dynamic payload) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.aiConfirmDelete,
        data: payload is Map ? payload : {},
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to confirm AI delete: ${e.toString()}',
      );
    }
  }

  /// POST /api/ai/confirm-classification
  /// Request: { "operation": "create", "arguments": { ... }, "really_needed": true }
  Future<dynamic> confirmAiClassification({
    required String operation,
    required Map<String, dynamic> arguments,
    required bool reallyNeeded,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.aiConfirmClassification,
        data: {
          'operation': operation,
          'arguments': arguments,
          'really_needed': reallyNeeded,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Failed to confirm AI classification: ${e.toString()}',
      );
    }
  }
}

class AiChatApiResponse {
  final String content;
  final Map<String, dynamic>? structuredData;
  final String? operation;
  final Map<String, dynamic>? arguments;
  final bool? reallyNeeded;

  const AiChatApiResponse({
    required this.content,
    this.structuredData,
    this.operation,
    this.arguments,
    this.reallyNeeded,
  });

  factory AiChatApiResponse.parse(dynamic rawData) {
    if (rawData == null) {
      return const AiChatApiResponse(content: 'No response received from AI.');
    }

    if (rawData is String) {
      // Check if the string itself is a JSON object
      final trimmed = rawData.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map<String, dynamic>) {
            return AiChatApiResponse._fromMap(decoded, fallbackContent: rawData);
          }
        } catch (_) {
          // If JSON decode fails, treat as plain text string
        }
      }
      return AiChatApiResponse(content: rawData);
    }

    if (rawData is Map<String, dynamic>) {
      return AiChatApiResponse._fromMap(rawData);
    }

    return AiChatApiResponse(content: rawData.toString());
  }

  factory AiChatApiResponse._fromMap(Map<String, dynamic> map, {String? fallbackContent}) {
    String textContent = '';
    if (map['content'] is String) {
      textContent = map['content'];
    } else if (map['message'] is String) {
      textContent = map['message'];
    } else if (map['response'] is String) {
      textContent = map['response'];
    } else if (map['answer'] is String) {
      textContent = map['answer'];
    } else if (map['detail'] is String) {
      textContent = map['detail'];
    } else {
      textContent = fallbackContent ?? map.toString();
    }

    final operation = map['operation']?.toString();
    final arguments = map['arguments'] is Map<String, dynamic>
        ? map['arguments'] as Map<String, dynamic>
        : (map['args'] is Map<String, dynamic> ? map['args'] as Map<String, dynamic> : null);
    final reallyNeeded = map['really_needed'] as bool? ?? map['reallyNeeded'] as bool?;

    return AiChatApiResponse(
      content: textContent,
      structuredData: map,
      operation: operation,
      arguments: arguments,
      reallyNeeded: reallyNeeded,
    );
  }
}

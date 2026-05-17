import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_id_generator.dart';
import '../../../providers/firebase_providers.dart';
import '../data/ai_tool_registry.dart';
import '../data/firestore_owner_dashboard_ai_repository.dart';
import '../data/firebase_owner_dashboard_ai_service.dart';
import '../data/owner_dashboard_ai_prompt_builder.dart';
import '../domain/models/ai_surface_response.dart';
import '../domain/repositories/owner_dashboard_ai_repository.dart';

enum AiConversationRole { user, assistant }

class AiConversationMessage {
  const AiConversationMessage({
    required this.id,
    required this.role,
    this.text,
    this.surface,
    required this.createdAt,
  });

  final String id;
  final AiConversationRole role;
  final String? text;
  final AiSurfaceResponse? surface;
  final DateTime createdAt;
}

class AiAssistantState {
  const AiAssistantState({
    this.messages = const [],
    this.isLoading = false,
    this.lastError,
    this.lastRenderedSurface,
    this.lastPrompt,
  });

  final List<AiConversationMessage> messages;
  final bool isLoading;
  final Object? lastError;
  final AiSurfaceResponse? lastRenderedSurface;
  final String? lastPrompt;

  AiAssistantState copyWith({
    List<AiConversationMessage>? messages,
    bool? isLoading,
    Object? lastError = _sentinel,
    Object? lastRenderedSurface = _sentinel,
    Object? lastPrompt = _sentinel,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      lastError: identical(lastError, _sentinel) ? this.lastError : lastError,
      lastRenderedSurface: identical(lastRenderedSurface, _sentinel)
          ? this.lastRenderedSurface
          : lastRenderedSurface as AiSurfaceResponse?,
      lastPrompt: identical(lastPrompt, _sentinel)
          ? this.lastPrompt
          : lastPrompt as String?,
    );
  }
}

final ownerDashboardAiRepositoryProvider = Provider<OwnerDashboardAiRepository>(
  (ref) {
    return FirestoreOwnerDashboardAiRepository(
      firestore: ref.watch(firestoreProvider),
    );
  },
);

final aiToolRegistryProvider = Provider<AiToolRegistry>((ref) {
  return AiToolRegistry(ref.watch(ownerDashboardAiRepositoryProvider));
});

final ownerDashboardAiPromptBuilderProvider =
    Provider<OwnerDashboardAiPromptBuilder>((ref) {
      return const OwnerDashboardAiPromptBuilder();
    });

final ownerDashboardAiServiceProvider = Provider<OwnerDashboardAiService>((
  ref,
) {
  return OwnerDashboardAiService(
    auth: ref.watch(firebaseAuthProvider),
    toolRegistry: ref.watch(aiToolRegistryProvider),
    promptBuilder: ref.watch(ownerDashboardAiPromptBuilderProvider),
  );
});

final aiControllerProvider =
    NotifierProvider.autoDispose<AiController, AiAssistantState>(
      AiController.new,
    );

class AiController extends Notifier<AiAssistantState> {
  OwnerDashboardAiService get _service =>
      ref.read(ownerDashboardAiServiceProvider);

  @override
  AiAssistantState build() {
    return const AiAssistantState();
  }

  Future<void> submitPrompt({
    required String prompt,
    required String salonId,
    required String localeCode,
  }) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty || state.isLoading) {
      return;
    }

    final nextMessages = [
      ...state.messages,
      AiConversationMessage(
        id: generateId(),
        role: AiConversationRole.user,
        text: trimmedPrompt,
        createdAt: DateTime.now(),
      ),
    ];

    state = state.copyWith(
      messages: nextMessages,
      isLoading: true,
      lastError: null,
      lastPrompt: trimmedPrompt,
    );

    try {
      final surface = await _service.generateSurface(
        salonId: salonId,
        prompt: trimmedPrompt,
        localeCode: localeCode,
      );

      state = state.copyWith(
        isLoading: false,
        lastError: null,
        lastRenderedSurface: surface,
        messages: [
          ...nextMessages,
          AiConversationMessage(
            id: generateId(),
            role: AiConversationRole.assistant,
            surface: surface,
            createdAt: DateTime.now(),
          ),
        ],
      );
    } on Object catch (error) {
      state = state.copyWith(isLoading: false, lastError: error);
    }
  }

  Future<void> retry({
    required String salonId,
    required String localeCode,
  }) async {
    final prompt = state.lastPrompt;
    if (prompt == null || prompt.trim().isEmpty) {
      return;
    }
    await submitPrompt(
      prompt: prompt,
      salonId: salonId,
      localeCode: localeCode,
    );
  }
}

const Object _sentinel = Object();

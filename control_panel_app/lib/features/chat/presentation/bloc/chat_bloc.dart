import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bookn_cp_app/services/websocket_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/create_conversation_usecase.dart';
import '../../domain/usecases/delete_conversation_usecase.dart';
import '../../domain/usecases/archive_conversation_usecase.dart';
import '../../domain/usecases/unarchive_conversation_usecase.dart';
import '../../domain/usecases/delete_message_usecase.dart';
import '../../domain/usecases/edit_message_usecase.dart';
import '../../domain/usecases/add_reaction_usecase.dart';
import '../../domain/usecases/remove_reaction_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/upload_attachment_usecase.dart';
import '../../domain/usecases/search_chats_usecase.dart';
import '../../domain/usecases/get_available_users_usecase.dart';
import '../../domain/usecases/get_admin_users_usecase.dart';
import '../../domain/usecases/update_user_status_usecase.dart';
import '../../domain/usecases/get_chat_settings_usecase.dart';
import '../../domain/usecases/update_chat_settings_usecase.dart';
import 'package:collection/collection.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase getConversationsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final CreateConversationUseCase createConversationUseCase;
  final DeleteConversationUseCase deleteConversationUseCase;
  final ArchiveConversationUseCase archiveConversationUseCase;
  final UnarchiveConversationUseCase unarchiveConversationUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;
  final EditMessageUseCase editMessageUseCase;
  final AddReactionUseCase addReactionUseCase;
  final RemoveReactionUseCase removeReactionUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final UploadAttachmentUseCase uploadAttachmentUseCase;
  final SearchChatsUseCase searchChatsUseCase;
  final GetAvailableUsersUseCase getAvailableUsersUseCase;
  final GetAdminUsersUseCase getAdminUsersUseCase;
  final UpdateUserStatusUseCase updateUserStatusUseCase;
  final GetChatSettingsUseCase getChatSettingsUseCase;
  final UpdateChatSettingsUseCase updateChatSettingsUseCase;
  final ChatWebSocketService webSocketService;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _conversationSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _presenceSubscription;

  ChatBloc({
    required this.getConversationsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.createConversationUseCase,
    required this.deleteConversationUseCase,
    required this.archiveConversationUseCase,
    required this.unarchiveConversationUseCase,
    required this.deleteMessageUseCase,
    required this.editMessageUseCase,
    required this.addReactionUseCase,
    required this.removeReactionUseCase,
    required this.markAsReadUseCase,
    required this.uploadAttachmentUseCase,
    required this.searchChatsUseCase,
    required this.getAvailableUsersUseCase,
    required this.getAdminUsersUseCase,
    required this.updateUserStatusUseCase,
    required this.getChatSettingsUseCase,
    required this.updateChatSettingsUseCase,
    required this.webSocketService,
  }) : super(const ChatInitial()) {
    on<InitializeChatEvent>(_onInitializeChat);
    on<LoadConversationsEvent>(_onLoadConversations);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<CreateConversationEvent>(_onCreateConversation);
    on<DeleteConversationEvent>(_onDeleteConversation);
    on<ArchiveConversationEvent>(_onArchiveConversation);
    on<UnarchiveConversationEvent>(_onUnarchiveConversation);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<EditMessageEvent>(_onEditMessage);
    on<AddReactionEvent>(_onAddReaction);
    on<RemoveReactionEvent>(_onRemoveReaction);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
    on<UploadAttachmentEvent>(_onUploadAttachment);
    on<SearchChatsEvent>(_onSearchChats);
    on<LoadAvailableUsersEvent>(_onLoadAvailableUsers);
    on<LoadAdminUsersEvent>(_onLoadAdminUsers);
    on<UpdateUserStatusEvent>(_onUpdateUserStatus);
    on<LoadChatSettingsEvent>(_onLoadChatSettings);
    on<UpdateChatSettingsEvent>(_onUpdateChatSettings);
    on<SendTypingIndicatorEvent>(_onSendTypingIndicator);
    on<WebSocketMessageReceivedEvent>(_onWebSocketMessageReceived);
    on<WebSocketConversationUpdatedEvent>(_onWebSocketConversationUpdated);
    on<WebSocketTypingIndicatorEvent>(_onWebSocketTypingIndicator);
    on<WebSocketPresenceUpdateEvent>(_onWebSocketPresenceUpdate);
    on<_UploadProgressInternal>(_onUploadProgressInternal);

    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    webSocketService.connect();

    _messageSubscription = webSocketService.messageEvents.listen((event) {
      add(WebSocketMessageReceivedEvent(event));
    });

    _conversationSubscription =
        webSocketService.conversationUpdates.listen((conversation) {
      add(WebSocketConversationUpdatedEvent(conversation));
    });

    _typingSubscription = webSocketService.typingEvents.listen((event) {
      add(WebSocketTypingIndicatorEvent(
        conversationId: event.conversationId,
        typingUserIds: event.typingUserIds,
      ));
    });

    _presenceSubscription = webSocketService.presenceEvents.listen((event) {
      add(WebSocketPresenceUpdateEvent(
        userId: event.userId,
        status: event.status,
        lastSeen: event.lastSeen,
      ));
    });
  }

  Future<void> _onInitializeChat(
    InitializeChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    // Load conversations and settings in parallel
    final conversationsResult = await getConversationsUseCase(
      const GetConversationsParams(),
    );

    final settingsResult = await getChatSettingsUseCase(NoParams());

    await conversationsResult.fold(
      (failure) async =>
          emit(ChatError(message: _mapFailureToMessage(failure))),
      (conversations) async {
        await settingsResult.fold(
          (failure) async =>
              emit(ChatError(message: _mapFailureToMessage(failure))),
          (settings) async => emit(ChatLoaded(
            conversations: conversations,
            settings: settings,
          )),
        );
      },
    );
  }

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) {
      emit(const ChatLoading());
    }

    final result = await getConversationsUseCase(
      GetConversationsParams(
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      ),
    );

    await result.fold(
      (failure) async =>
          emit(ChatError(message: _mapFailureToMessage(failure))),
      (conversations) async {
        if (state is ChatLoaded) {
          final currentState = state as ChatLoaded;
          emit(currentState.copyWith(
            conversations: event.pageNumber == 1
                ? conversations
                : [...currentState.conversations, ...conversations],
          ));
        } else {
          emit(ChatLoaded(conversations: conversations));
        }
      },
    );
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    emit(currentState.copyWith(isLoadingMessages: true));

    final result = await getMessagesUseCase(
      GetMessagesParams(
        conversationId: event.conversationId,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
        beforeMessageId: event.beforeMessageId,
      ),
    );

    await result.fold(
      (failure) async => emit(currentState.copyWith(
        isLoadingMessages: false,
        error: _mapFailureToMessage(failure),
      )),
      (messages) async {
        final currentMessages =
            currentState.messages[event.conversationId] ?? [];
        final updatedMessages = event.pageNumber == 1
            ? messages
            : [...currentMessages, ...messages];

        emit(currentState.copyWith(
          messages: {
            ...currentState.messages,
            event.conversationId: updatedMessages,
          },
          isLoadingMessages: false,
        ));
      },
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;

    // Optimistic update
    final tempMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: event.conversationId,
      // Use actual current user id if provided to ensure correct alignment
      senderId: (event.currentUserId != null && event.currentUserId!.isNotEmpty)
          ? event.currentUserId!
          : 'current_user',
      messageType: event.messageType,
      content: event.content,
      location: event.location,
      replyToMessageId: event.replyToMessageId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'sending',
    );

    final currentMessages = currentState.messages[event.conversationId] ?? [];
    emit(currentState.copyWith(
      messages: {
        ...currentState.messages,
        event.conversationId: [tempMessage, ...currentMessages],
      },
    ));

    final result = await sendMessageUseCase(
      SendMessageParams(
        conversationId: event.conversationId,
        messageType: event.messageType,
        content: event.content,
        location: event.location,
        replyToMessageId: event.replyToMessageId,
        attachmentIds: event.attachmentIds,
      ),
    );

    await result.fold(
      (failure) async {
        // Remove optimistic message and show error
        emit(currentState.copyWith(
          messages: {
            ...currentState.messages,
            event.conversationId: currentMessages,
          },
          error: _mapFailureToMessage(failure),
        ));
      },
      (message) async {
        // Replace temp message with real one
        final updatedMessages = [
          message,
          ...currentMessages.where((m) => m.id != tempMessage.id),
        ];
        emit(currentState.copyWith(
          messages: {
            ...currentState.messages,
            event.conversationId: updatedMessages,
          },
        ));
      },
    );
  }

  // ... باقي event handlers ...

  Future<void> _onSendTypingIndicator(
    SendTypingIndicatorEvent event,
    Emitter<ChatState> emit,
  ) async {
    webSocketService.sendTypingIndicator(
      event.conversationId,
      event.isTyping,
    );
  }

  Future<void> _onWebSocketMessageReceived(
    WebSocketMessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final messageEvent = event.messageEvent;

    switch (messageEvent.type) {
      case MessageEventType.newMessage:
        if (messageEvent.message != null) {
          final currentMessages =
              currentState.messages[messageEvent.conversationId] ?? [];
        // Insert message at top (reverse list), update conversation ordering by updatedAt
        final List<Message> newList = [messageEvent.message!, ...currentMessages];
        // Also bump the conversation's updatedAt if present
        final conversations = currentState.conversations.map((c) {
          if (c.id == messageEvent.conversationId) {
            return Conversation(
              id: c.id,
              conversationType: c.conversationType,
              title: c.title,
              description: c.description,
              avatar: c.avatar,
              createdAt: c.createdAt,
              updatedAt: messageEvent.message!.updatedAt,
              lastMessage: messageEvent.message!,
              unreadCount: c.unreadCount,
              isArchived: c.isArchived,
              isMuted: c.isMuted,
              propertyId: c.propertyId,
              participants: c.participants,
            );
          }
          return c;
        }).toList();
        conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        emit(currentState.copyWith(
          messages: {
            ...currentState.messages,
            messageEvent.conversationId: newList,
          },
          conversations: conversations,
        ));
        } else {
          // في حال لم يصل جسم الرسالة (FCM data فقط)، اجلب آخر الرسائل لهذا الحوار
          final result = await getMessagesUseCase(
            GetMessagesParams(
              conversationId: messageEvent.conversationId,
              pageNumber: 1,
              pageSize: 50,
            ),
          );
          await result.fold(
            (failure) async {
              emit(currentState.copyWith(error: _mapFailureToMessage(failure)));
            },
            (messages) async {
              emit(currentState.copyWith(
                messages: {
                  ...currentState.messages,
                  messageEvent.conversationId: messages,
                },
              ));
            },
          );
        }
        break;
      case MessageEventType.statusUpdated:
        {
          // Update status locally for the specific messageId if present
          if (messageEvent.messageId != null && messageEvent.status != null) {
            final currentMessages = currentState.messages[messageEvent.conversationId] ?? [];
            bool found = false;
            final updatedMessages = currentMessages.map((m) {
              if (m.id == messageEvent.messageId) {
                found = true;
                return Message(
                  id: m.id,
                  conversationId: m.conversationId,
                  senderId: m.senderId,
                  messageType: m.messageType,
                  content: m.content,
                  location: m.location,
                  replyToMessageId: m.replyToMessageId,
                  reactions: m.reactions,
                  attachments: m.attachments,
                  createdAt: m.createdAt,
                  updatedAt: DateTime.now(),
                  status: messageEvent.status!,
                  isEdited: m.isEdited,
                  editedAt: m.editedAt,
                  deliveryReceipt: m.deliveryReceipt,
                );
              }
              return m;
            }).toList();

            if (found) {
              emit(currentState.copyWith(
                messages: {
                  ...currentState.messages,
                  messageEvent.conversationId: updatedMessages,
                },
              ));
            } else {
              // If message not found in memory (e.g., user in list view), fetch latest page
              final result = await getMessagesUseCase(
                GetMessagesParams(
                  conversationId: messageEvent.conversationId,
                  pageNumber: 1,
                  pageSize: 50,
                ),
              );
              await result.fold(
                (failure) async => emit(currentState.copyWith(error: _mapFailureToMessage(failure))),
                (messages) async => emit(currentState.copyWith(messages: {
                  ...currentState.messages,
                  messageEvent.conversationId: messages,
                })),
              );
            }
          } else {
            // Fallback: fetch latest messages if we lack ids
            final result = await getMessagesUseCase(
              GetMessagesParams(
                conversationId: messageEvent.conversationId,
                pageNumber: 1,
                pageSize: 50,
              ),
            );
            await result.fold(
              (failure) async => emit(currentState.copyWith(error: _mapFailureToMessage(failure))),
              (messages) async => emit(currentState.copyWith(messages: {
                ...currentState.messages,
                messageEvent.conversationId: messages,
              })),
            );
          }
        }
        break;
      case MessageEventType.reactionAdded:
      case MessageEventType.reactionRemoved:
        {
          if (messageEvent.messageId != null && messageEvent.reaction != null) {
            final currentMessages = currentState.messages[messageEvent.conversationId] ?? [];
            final updatedMessages = currentMessages.map((m) {
              if (m.id == messageEvent.messageId) {
                if (messageEvent.type == MessageEventType.reactionAdded) {
                  final reactions = List<MessageReaction>.from(m.reactions);
                  final exists = reactions.any((r) => r.userId == messageEvent.reaction!.userId && r.reactionType == messageEvent.reaction!.reactionType);
                  if (!exists) {
                    reactions.add(messageEvent.reaction!);
                  }
                  return Message(
                    id: m.id,
                    conversationId: m.conversationId,
                    senderId: m.senderId,
                    messageType: m.messageType,
                    content: m.content,
                    location: m.location,
                    replyToMessageId: m.replyToMessageId,
                    reactions: reactions,
                    attachments: m.attachments,
                    createdAt: m.createdAt,
                    updatedAt: DateTime.now(),
                    status: m.status,
                    isEdited: m.isEdited,
                    editedAt: m.editedAt,
                    deliveryReceipt: m.deliveryReceipt,
                  );
                } else {
                  final reactions = m.reactions
                      .where((r) => !(r.userId == messageEvent.reaction!.userId && r.reactionType == messageEvent.reaction!.reactionType))
                      .toList();
                  return Message(
                    id: m.id,
                    conversationId: m.conversationId,
                    senderId: m.senderId,
                    messageType: m.messageType,
                    content: m.content,
                    location: m.location,
                    replyToMessageId: m.replyToMessageId,
                    reactions: reactions,
                    attachments: m.attachments,
                    createdAt: m.createdAt,
                    updatedAt: DateTime.now(),
                    status: m.status,
                    isEdited: m.isEdited,
                    editedAt: m.editedAt,
                    deliveryReceipt: m.deliveryReceipt,
                  );
                }
              }
              return m;
            }).toList();

            emit(currentState.copyWith(
              messages: {
                ...currentState.messages,
                messageEvent.conversationId: updatedMessages,
              },
            ));
          } else {
            final result = await getMessagesUseCase(
              GetMessagesParams(
                conversationId: messageEvent.conversationId,
                pageNumber: 1,
                pageSize: 50,
              ),
            );
            await result.fold(
              (failure) async => emit(currentState.copyWith(error: _mapFailureToMessage(failure))),
              (messages) async => emit(currentState.copyWith(messages: {
                ...currentState.messages,
                messageEvent.conversationId: messages,
              })),
            );
          }
        }
        break;
      case MessageEventType.edited:
        if (messageEvent.message != null) {
          final currentMessages =
              currentState.messages[messageEvent.conversationId] ?? [];
          final updatedMessages = currentMessages.map((m) {
            return m.id == messageEvent.message!.id ? messageEvent.message! : m;
          }).toList();
          emit(currentState.copyWith(
            messages: {
              ...currentState.messages,
              messageEvent.conversationId: updatedMessages,
            },
          ));
        }
        break;

      case MessageEventType.deleted:
        if (messageEvent.messageId != null) {
          final currentMessages =
              currentState.messages[messageEvent.conversationId] ?? [];
          final updatedMessages = currentMessages
              .where((m) => m.id != messageEvent.messageId)
              .toList();
          emit(currentState.copyWith(
            messages: {
              ...currentState.messages,
              messageEvent.conversationId: updatedMessages,
            },
          ));
        }
        break;

      default:
        break;
    }
  }

  Future<void> _onWebSocketConversationUpdated(
    WebSocketConversationUpdatedEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final existingIndex = currentState.conversations.indexWhere((c) => c.id == event.conversation.id);
    // Merge or insert, then sort by updatedAt desc to keep list stable
    final List<Conversation> merged = [];
    bool inserted = false;
    for (int i = 0; i < currentState.conversations.length; i++) {
      final c = currentState.conversations[i];
      if (c.id == event.conversation.id) {
        if (!inserted) {
          merged.add(event.conversation);
          inserted = true;
        }
      } else {
        merged.add(c);
      }
    }
    if (!inserted) merged.add(event.conversation);
    merged.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    emit(currentState.copyWith(conversations: merged));
  }

  Future<void> _onWebSocketTypingIndicator(
    WebSocketTypingIndicatorEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    emit(currentState.copyWith(
      typingUsers: {
        ...currentState.typingUsers,
        event.conversationId: event.typingUserIds,
      },
    ));
  }

  Future<void> _onWebSocketPresenceUpdate(
    WebSocketPresenceUpdateEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    emit(currentState.copyWith(
      userPresence: {
        ...currentState.userPresence,
        event.userId: UserPresence(
          status: event.status,
          lastSeen: event.lastSeen,
        ),
      },
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'حدث خطأ في الخادم';
      case NetworkFailure:
        return 'لا يوجد اتصال بالإنترنت';
      case CacheFailure:
        return 'حدث خطأ في التخزين المحلي';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _conversationSubscription?.cancel();
    _typingSubscription?.cancel();
    _presenceSubscription?.cancel();
    webSocketService.dispose();
    return super.close();
  }

  Future<void> _onCreateConversation(
    CreateConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;

    emit(const ConversationCreating());

    // منع أي محادثة ليست direct أو تتجاوز شخصًا واحدًا (غير المستخدم الحالي)
    if (event.conversationType != 'direct' || event.participantIds.length != 1) {
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(error: 'يُسمح فقط بمحادثات ثنائية مباشرة'));
      } else {
        emit(const ChatError(message: 'يُسمح فقط بمحادثات ثنائية مباشرة'));
      }
      return;
    }

    // للمحادثات الفردية، تحقق من وجود محادثة سابقة
    if (event.conversationType == 'direct' && currentState is ChatLoaded) {
      Conversation? existingConversation;

      for (final conversation in currentState.conversations) {
        if (conversation.conversationType != 'direct') continue;
        if (conversation.participants.length != 2) continue;

        final participantIds = conversation.participants
            .map((participant) => participant.id)
            .toList();

        bool hasTargetParticipant = false;
        for (final targetId in event.participantIds) {
          if (participantIds.contains(targetId)) {
            hasTargetParticipant = true;
            break;
          }
        }

        if (hasTargetParticipant) {
          existingConversation = conversation;
          break;
        }
      }

      if (existingConversation != null) {
        emit(ConversationCreated(
          conversation: existingConversation,
          message: 'المحادثة موجودة بالفعل',
        ));

        await Future.delayed(const Duration(milliseconds: 100));
        emit(currentState);
        return;
      }
    }

    // إنشاء محادثة جديدة
    final result = await createConversationUseCase(
      CreateConversationParams(
        participantIds: event.participantIds,
        conversationType: event.conversationType,
        title: event.title,
        description: event.description,
        propertyId: event.propertyId,
      ),
    );

    await result.fold(
      (failure) async {
        if (currentState is ChatLoaded) {
          emit(currentState.copyWith(error: _mapFailureToMessage(failure)));
        } else {
          emit(ChatError(message: _mapFailureToMessage(failure)));
        }
      },
      (conversation) async {
        emit(ConversationCreated(conversation: conversation));

        if (currentState is ChatLoaded) {
          final List<Conversation> updatedConversations = [
            conversation,
          ];

          for (final conv in currentState.conversations) {
            if (conv.id != conversation.id) {
              updatedConversations.add(conv);
            }
          }

          await Future.delayed(const Duration(milliseconds: 100));

          emit(currentState.copyWith(
            conversations: updatedConversations,
          ));
        } else {
          add(const LoadConversationsEvent());
        }
      },
    );
  }

  Future<void> _onDeleteConversation(
      DeleteConversationEvent event, Emitter<ChatState> emit) async {
    final result = await deleteConversationUseCase(
      DeleteConversationParams(conversationId: event.conversationId),
    );

    await result.fold(
      (failure) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          emit(current.copyWith(error: _mapFailureToMessage(failure)));
        }
      },
      (_) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          emit(current.copyWith(
            conversations: current.conversations
                .where((c) => c.id != event.conversationId)
                .toList(),
          ));
        }
      },
    );
  }

  Future<void> _onArchiveConversation(
      ArchiveConversationEvent event, Emitter<ChatState> emit) async {
    final result = await archiveConversationUseCase(
      ArchiveConversationParams(conversationId: event.conversationId),
    );

    await result.fold(
      (failure) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          emit(current.copyWith(error: _mapFailureToMessage(failure)));
        }
      },
      (_) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          final updated = current.conversations.map((c) {
            if (c.id == event.conversationId) {
              return Conversation(
                id: c.id,
                conversationType: c.conversationType,
                title: c.title,
                description: c.description,
                avatar: c.avatar,
                createdAt: c.createdAt,
                updatedAt: DateTime.now(),
                lastMessage: c.lastMessage,
                unreadCount: c.unreadCount,
                isArchived: true,
                isMuted: c.isMuted,
                propertyId: c.propertyId,
                participants: c.participants,
              );
            }
            return c;
          }).toList();
          emit(current.copyWith(conversations: updated));
        }
      },
    );
  }

  Future<void> _onUnarchiveConversation(
      UnarchiveConversationEvent event, Emitter<ChatState> emit) async {
    final result = await unarchiveConversationUseCase(
      UnarchiveConversationParams(conversationId: event.conversationId),
    );

    await result.fold(
      (failure) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          emit(current.copyWith(error: _mapFailureToMessage(failure)));
        }
      },
      (_) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          final updated = current.conversations.map((c) {
            if (c.id == event.conversationId) {
              return Conversation(
                id: c.id,
                conversationType: c.conversationType,
                title: c.title,
                description: c.description,
                avatar: c.avatar,
                createdAt: c.createdAt,
                updatedAt: DateTime.now(),
                lastMessage: c.lastMessage,
                unreadCount: c.unreadCount,
                isArchived: false,
                isMuted: c.isMuted,
                propertyId: c.propertyId,
                participants: c.participants,
              );
            }
            return c;
          }).toList();
          emit(current.copyWith(conversations: updated));
        }
      },
    );
  }

  Future<void> _onDeleteMessage(
      DeleteMessageEvent event, Emitter<ChatState> emit) async {
    final result = await deleteMessageUseCase(
      DeleteMessageParams(messageId: event.messageId),
    );

    await result.fold(
      (failure) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          emit(current.copyWith(error: _mapFailureToMessage(failure)));
        }
      },
      (_) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          // ابحث عن المحادثة التي تحتوي الرسالة واحذفها من قائمتها إن وُجدت
          final updatedMessages = <String, List<Message>>{};
          current.messages.forEach((convId, msgs) {
            updatedMessages[convId] = msgs.where((m) => m.id != event.messageId).toList();
          });
          emit(current.copyWith(messages: updatedMessages));
        }
      },
    );
  }

  Future<void> _onEditMessage(
      EditMessageEvent event, Emitter<ChatState> emit) async {
    final result = await editMessageUseCase(
      EditMessageParams(messageId: event.messageId, content: event.content),
    );

    await result.fold(
      (failure) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          emit(current.copyWith(error: _mapFailureToMessage(failure)));
        }
      },
      (message) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          final convId = message.conversationId;
          final msgs = current.messages[convId] ?? [];
          final updated = msgs.map((m) => m.id == message.id ? message : m).toList();
          emit(current.copyWith(messages: {
            ...current.messages,
            convId: updated,
          }));
        }
      },
    );
  }

  Future<void> _onAddReaction(
      AddReactionEvent event, Emitter<ChatState> emit) async {
    // Optimistic update: add reaction locally
    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      final Map<String, List<Message>> updated = {...current.messages};
      updated.forEach((convId, msgs) {
        for (int i = 0; i < msgs.length; i++) {
          final m = msgs[i];
          if (m.id == event.messageId) {
            final reactions = List<MessageReaction>.from(m.reactions);
            reactions.add(MessageReaction(
              id: 'temp_${DateTime.now().microsecondsSinceEpoch}',
              messageId: m.id,
              userId: (event.currentUserId != null && event.currentUserId!.isNotEmpty)
                  ? event.currentUserId!
                  : 'current_user',
              reactionType: event.reactionType,
            ));
            msgs[i] = Message(
              id: m.id,
              conversationId: m.conversationId,
              senderId: m.senderId,
              messageType: m.messageType,
              content: m.content,
              location: m.location,
              replyToMessageId: m.replyToMessageId,
              reactions: reactions,
              attachments: m.attachments,
              createdAt: m.createdAt,
              updatedAt: DateTime.now(),
              status: m.status,
              isEdited: m.isEdited,
              editedAt: m.editedAt,
              deliveryReceipt: m.deliveryReceipt,
            );
            break;
          }
        }
      });
      emit(current.copyWith(messages: updated));
    }

    final result = await addReactionUseCase(
      AddReactionParams(messageId: event.messageId, reactionType: event.reactionType),
    );
    await result.fold(
      (failure) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          // rollback optimistic add
          final Map<String, List<Message>> rolled = {...current.messages};
          rolled.forEach((convId, msgs) {
            for (int i = 0; i < msgs.length; i++) {
              final m = msgs[i];
              if (m.id == event.messageId) {
                final reactions = m.reactions.where((r) => !(r.id.startsWith('temp_') && r.reactionType == event.reactionType)).toList();
                msgs[i] = Message(
                  id: m.id,
                  conversationId: m.conversationId,
                  senderId: m.senderId,
                  messageType: m.messageType,
                  content: m.content,
                  location: m.location,
                  replyToMessageId: m.replyToMessageId,
                  reactions: reactions,
                  attachments: m.attachments,
                  createdAt: m.createdAt,
                  updatedAt: m.updatedAt,
                  status: m.status,
                  isEdited: m.isEdited,
                  editedAt: m.editedAt,
                  deliveryReceipt: m.deliveryReceipt,
                );
                break;
              }
            }
          });
          emit(current.copyWith(messages: rolled, error: _mapFailureToMessage(failure)));
        }
      },
      (_) async {},
    );
  }

  Future<void> _onRemoveReaction(
      RemoveReactionEvent event, Emitter<ChatState> emit) async {
    // Optimistic update: remove reaction locally
    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      final Map<String, List<Message>> updated = {...current.messages};
      updated.forEach((convId, msgs) {
        for (int i = 0; i < msgs.length; i++) {
          final m = msgs[i];
          if (m.id == event.messageId) {
            final reactions = m.reactions.where((r) => r.reactionType != event.reactionType).toList();
            msgs[i] = Message(
              id: m.id,
              conversationId: m.conversationId,
              senderId: m.senderId,
              messageType: m.messageType,
              content: m.content,
              location: m.location,
              replyToMessageId: m.replyToMessageId,
              reactions: reactions,
              attachments: m.attachments,
              createdAt: m.createdAt,
              updatedAt: DateTime.now(),
              status: m.status,
              isEdited: m.isEdited,
              editedAt: m.editedAt,
              deliveryReceipt: m.deliveryReceipt,
            );
            break;
          }
        }
      });
      emit(current.copyWith(messages: updated));
    }

    final result = await removeReactionUseCase(
      RemoveReactionParams(messageId: event.messageId, reactionType: event.reactionType),
    );
    await result.fold(
      (failure) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          // rollback removal by refetching this message list (fallback)
          emit(current.copyWith(error: _mapFailureToMessage(failure)));
        }
      },
      (_) async {},
    );
  }

  Future<void> _onMarkMessagesAsRead(
      MarkMessagesAsReadEvent event, Emitter<ChatState> emit) async {
    final result = await markAsReadUseCase(
      MarkAsReadParams(
        conversationId: event.conversationId,
        messageIds: event.messageIds,
      ),
    );
    await result.fold(
      (failure) async {
        if (state is ChatLoaded) {
          final current = state as ChatLoaded;
          emit(current.copyWith(error: _mapFailureToMessage(failure)));
        }
      },
      (_) async {
        // No-op; optimistic UI already shows as read
      },
    );
  }

  Future<void> _onUploadAttachment(
      UploadAttachmentEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    emit(current.copyWith(uploadingAttachment: null, uploadProgress: 0));

    final result = await uploadAttachmentUseCase(
      UploadAttachmentParams(
        conversationId: event.conversationId,
        filePath: event.filePath,
        messageType: event.messageType,
        onSendProgress: (sent, total) {
          add(_UploadProgressInternal(sent: sent, total: total));
        },
      ),
    );

    await result.fold(
      (failure) async {
        emit(current.copyWith(
          uploadingAttachment: null,
          uploadProgress: null,
          error: _mapFailureToMessage(failure),
        ));
      },
      (attachment) async {
        emit(current.copyWith(
          uploadingAttachment: attachment,
          uploadProgress: 1.0,
        ));
      },
    );
  }

  Future<void> _onSearchChats(
      SearchChatsEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final result = await searchChatsUseCase(
      SearchChatsParams(
        query: event.query,
        conversationId: event.conversationId,
        messageType: event.messageType,
        senderId: event.senderId,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        page: event.page,
        limit: event.limit,
      ),
    );
    await result.fold(
      (failure) async => emit(current.copyWith(error: _mapFailureToMessage(failure))),
      (res) async => emit(current.copyWith(searchResult: res)),
    );
  }

  Future<void> _onLoadAvailableUsers(
      LoadAvailableUsersEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final result = await getAvailableUsersUseCase(
      GetAvailableUsersParams(
          userType: event.userType, propertyId: event.propertyId),
    );
    await result.fold(
      (failure) async =>
          emit(current.copyWith(error: _mapFailureToMessage(failure))),
      (users) async => emit(current.copyWith(availableUsers: users)),
    );
  }

  Future<void> _onUpdateUserStatus(
      UpdateUserStatusEvent event, Emitter<ChatState> emit) async {
    final result = await updateUserStatusUseCase(UpdateUserStatusParams(status: event.status));
    await result.fold((failure) async {
      if (state is ChatLoaded) {
        final current = state as ChatLoaded;
        emit(current.copyWith(error: _mapFailureToMessage(failure)));
      }
    }, (_) async {});
  }

  Future<void> _onLoadChatSettings(
      LoadChatSettingsEvent event, Emitter<ChatState> emit) async {
    final result = await getChatSettingsUseCase(NoParams());
    await result.fold((failure) async {
      if (state is ChatLoaded) {
        final current = state as ChatLoaded;
        emit(current.copyWith(error: _mapFailureToMessage(failure)));
      }
    }, (settings) async {
      if (state is ChatLoaded) {
        final current = state as ChatLoaded;
        emit(current.copyWith(settings: settings));
      }
    });
  }

  Future<void> _onUpdateChatSettings(
      UpdateChatSettingsEvent event, Emitter<ChatState> emit) async {
    final result = await updateChatSettingsUseCase(UpdateChatSettingsParams(
      notificationsEnabled: event.notificationsEnabled,
      soundEnabled: event.soundEnabled,
      showReadReceipts: event.showReadReceipts,
      showTypingIndicator: event.showTypingIndicator,
      theme: event.theme,
      fontSize: event.fontSize,
      autoDownloadMedia: event.autoDownloadMedia,
      backupMessages: event.backupMessages,
    ));
    await result.fold((failure) async {
      if (state is ChatLoaded) {
        final current = state as ChatLoaded;
        emit(current.copyWith(error: _mapFailureToMessage(failure)));
      }
    }, (settings) async {
      if (state is ChatLoaded) {
        final current = state as ChatLoaded;
        emit(current.copyWith(settings: settings));
      }
    });
  }

  // Internal event for updating upload progress (not exposed)
  Future<void> _onUploadProgressInternal(
      _UploadProgressInternal event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final progress = event.total > 0 ? event.sent / event.total : 0.0;
    emit(current.copyWith(uploadProgress: progress));
  }

  Future<void> _onLoadAdminUsers(
      LoadAdminUsersEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final result = await getAdminUsersUseCase(NoParams());
    await result.fold(
      (failure) async =>
          emit(current.copyWith(error: _mapFailureToMessage(failure))),
      (users) async => emit(current.copyWith(adminUsers: users)),
    );
  }
}

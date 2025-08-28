using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using MediatR;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using AutoMapper;
using System.Text.Json;
using YemenBooking.Application.Commands.Chat;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Core.Settings;

namespace YemenBooking.Application.Handlers.Commands.Chat
{
    /// <summary>
    /// معالج أمر إرسال رسالة في المحادثة
    /// </summary>
    public class SendMessageCommandHandler : IRequestHandler<SendMessageCommand, ResultDto<ChatMessageDto>>
    {
        private readonly IChatConversationRepository _conversationRepository;
        private readonly IChatMessageRepository _messageRepository;
        private readonly IChatAttachmentRepository _attachmentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        private readonly IFileStorageService _fileStorageService;
        private readonly IMapper _mapper;
        private readonly IFirebaseService _firebaseService;
        private readonly ChatAttachmentSettings _attachmentSettings;
        private readonly ILogger<SendMessageCommandHandler> _logger;

        public SendMessageCommandHandler(
            IChatConversationRepository conversationRepository,
            IChatMessageRepository messageRepository,
            IChatAttachmentRepository attachmentRepository,
            IUnitOfWork unitOfWork,
            ICurrentUserService currentUserService,
            IFileStorageService fileStorageService,
            IMapper mapper,
            IFirebaseService firebaseService,
            IOptions<ChatAttachmentSettings> attachmentSettings,
            ILogger<SendMessageCommandHandler> logger)
        {
            _conversationRepository = conversationRepository;
            _messageRepository = messageRepository;
            _attachmentRepository = attachmentRepository;
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
            _fileStorageService = fileStorageService;
            _mapper = mapper;
            _firebaseService = firebaseService;
            _attachmentSettings = attachmentSettings.Value;
            _logger = logger;
        }

        public async Task<ResultDto<ChatMessageDto>> Handle(SendMessageCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var userId = _currentUserService.UserId;
                _logger.LogInformation("المستخدم {UserId} يرسل رسالة في المحادثة {ConversationId}", userId, request.ConversationId);

                // تحقق من وجود المحادثة
                var conversation = await _conversationRepository.GetByIdAsync(request.ConversationId, cancellationToken);
                if (conversation == null)
                    return ResultDto<ChatMessageDto>.Failed("المحادثة غير موجودة", errorCode: "conversation_not_found");

                // تحقق من صلاحيات الإرسال
                // if (!conversation.Participants.Any(p => p.Id == userId))
                //     return ResultDto<ChatMessageDto>.Failed("لا يحق لك إرسال رسالة في هذه المحادثة", errorCode: "permission_denied");

                // إنشاء الرسالة
                var message = new ChatMessage
                {
                    Id = Guid.NewGuid(),
                    ConversationId = request.ConversationId,
                    SenderId = userId,
                    MessageType = request.MessageType,
                    Content = request.Content,
                    LocationJson = request.LocationJson,
                    ReplyToMessageId = request.ReplyToMessageId,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                await _unitOfWork.Repository<ChatMessage>().AddAsync(message, cancellationToken);

                // معالجة المرفقات
                if (request.Attachments != null)
                {
                    var folder = $"{_attachmentSettings.BasePath}/{request.ConversationId}";
                    foreach (var file in request.Attachments)
                    {
                        var result = await _fileStorageService.UploadFileAsync(file.OpenReadStream(), file.FileName, file.ContentType, folder, cancellationToken);
                        if (result.IsSuccess)
                        {
                            var attachment = new ChatAttachment
                            {
                                Id = Guid.NewGuid(),
                                ConversationId = request.ConversationId,
                                FileName = result.FileName ?? file.FileName,
                                ContentType = result.ContentType ?? string.Empty,
                                FileSize = result.FileSizeBytes,
                                FilePath = result.FilePath ?? string.Empty,
                                UploadedBy = userId,
                                CreatedAt = DateTime.UtcNow
                            };
                            await _unitOfWork.Repository<ChatAttachment>().AddAsync(attachment, cancellationToken);
                        }
                    }
                }

                await _unitOfWork.SaveChangesAsync(cancellationToken);

                var messageDto = _mapper.Map<ChatMessageDto>(message);

                // إشعارات للمشاركين الآخرين
                var participants = conversation.Participants.Where(p => p.Id != userId).ToList();
                foreach (var p in participants)
                {
                    await _firebaseService.SendNotificationAsync($"user_{p.Id}", "رسالة جديدة", message.Content ?? string.Empty, new Dictionary<string, string>
                    {
                        { "type", "new_message" },
                        { "conversation_id", request.ConversationId.ToString() },
                        { "message_id", message.Id.ToString() }
                    }, cancellationToken);
                }

                return ResultDto<ChatMessageDto>.Ok(messageDto, "تم إرسال الرسالة بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء إرسال الرسالة");
                return ResultDto<ChatMessageDto>.Failed("حدث خطأ أثناء إرسال الرسالة");
            }
        }
    }
}
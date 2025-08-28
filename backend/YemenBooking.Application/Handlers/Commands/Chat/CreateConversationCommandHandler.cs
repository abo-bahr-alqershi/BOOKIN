using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Commands.Chat;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Interfaces.Services;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

namespace YemenBooking.Application.Handlers.Commands.Chat
{
    public class CreateConversationCommandHandler : IRequestHandler<CreateConversationCommand, ResultDto<ChatConversationDto>>
    {
        private readonly IChatConversationRepository _conversationRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly IFirebaseService _firebaseService;
        private readonly ILogger<CreateConversationCommandHandler> _logger;
        private readonly IRepository<User> _userRepository; // إضافة مستودع المستخدمين

        public CreateConversationCommandHandler(
            IChatConversationRepository conversationRepository,
            IUnitOfWork unitOfWork,
            ICurrentUserService currentUserService,
            IMapper mapper,
            IFirebaseService firebaseService,
            ILogger<CreateConversationCommandHandler> logger)
        {
            _conversationRepository = conversationRepository;
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
            _mapper = mapper;
            _firebaseService = firebaseService;
            _logger = logger;
            _userRepository = unitOfWork.Repository<User>(); // الحصول على مستودع المستخدمين
        }

        public async Task<ResultDto<ChatConversationDto>> Handle(CreateConversationCommand request, CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation("إنشاء محادثة جديدة للمستخدم {UserId}", _currentUserService.UserId);

                // تحقق من صحة البيانات الأساسية
                if (request.ParticipantIds == null || request.ParticipantIds.Count == 0)
                {
                    return ResultDto<ChatConversationDto>.Failed("قائمة المشاركين مطلوبة");
                }
                if (string.IsNullOrWhiteSpace(request.ConversationType))
                {
                    return ResultDto<ChatConversationDto>.Failed("نوع المحادثة مطلوب");
                }

                var conversation = new ChatConversation
                {
                    Id = Guid.NewGuid(),
                    ConversationType = request.ConversationType,
                    Title = request.Title,
                    Description = request.Description,
                    PropertyId = request.PropertyId,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    IsArchived = false,
                    IsMuted = false
                };

                // إضافة المشاركين
                var currentUserId = _currentUserService.UserId;
                var participantIds = request.ParticipantIds.Contains(currentUserId)
                    ? request.ParticipantIds
                    : request.ParticipantIds.Append(currentUserId).ToList();

                // للمحادثات الفردية: تحقق إن كانت موجودة مسبقًا
                if (string.Equals(request.ConversationType, "direct", StringComparison.OrdinalIgnoreCase) && participantIds.Count == 2)
                {
                    var existing = await _conversationRepository.GetDirectConversationAsync(participantIds[0], participantIds[1], cancellationToken);
                    if (existing != null)
                    {
                        // أعد المحادثة الحالية بكامل تفاصيلها
                        var dtoExisting = _mapper.Map<ChatConversationDto>(existing);
                        return ResultDto<ChatConversationDto>.Ok(dtoExisting, "المحادثة موجودة بالفعل");
                    }
                }

                // *** الحل: جلب المستخدمين الفعليين من قاعدة البيانات ***
                var users = await _userRepository.GetQueryable()
                    .Where(u => participantIds.Contains(u.Id))
                    .ToListAsync(cancellationToken);

                // التحقق من وجود جميع المستخدمين
                if (users.Count != participantIds.Count)
                {
                    var missingIds = participantIds.Except(users.Select(u => u.Id));
                    _logger.LogError("بعض المستخدمين غير موجودين: {MissingIds}", string.Join(", ", missingIds));
                    return ResultDto<ChatConversationDto>.Failed("بعض المستخدمين المحددين غير موجودين");
                }

                // إضافة المستخدمين الفعليين للمحادثة
                foreach (var user in users)
                {
                    conversation.Participants.Add(user);
                }

                // حفظ المحادثة
                await _conversationRepository.AddAsync(conversation, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);

                // إرسال الإشعارات
                foreach (var participant in users.Where(u => u.Id != currentUserId))
                {
                    try
                    {
                        await _firebaseService.SendNotificationAsync(
                            $"user_{participant.Id}", 
                            "محادثة جديدة", 
                            conversation.Title ?? $"محادثة مع {users.FirstOrDefault(u => u.Id == currentUserId)?.Name ?? "مستخدم"}", 
                            new System.Collections.Generic.Dictionary<string, string>
                            {
                                { "type", "conversation_created" },
                                { "conversation_id", conversation.Id.ToString() }
                            }, 
                            cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "فشل إرسال إشعار للمستخدم {UserId}", participant.Id);
                    }
                }

                // تحميل المحادثة بتفاصيلها الكاملة
                var created = await _conversationRepository.GetByIdWithDetailsAsync(conversation.Id, cancellationToken);
                if (created == null)
                {
                    return ResultDto<ChatConversationDto>.Failed("تعذر تحميل بيانات المحادثة بعد إنشائها");
                }
                
                var dto = _mapper.Map<ChatConversationDto>(created);
                return ResultDto<ChatConversationDto>.Ok(dto, "تم إنشاء المحادثة بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء إنشاء المحادثة");
                return ResultDto<ChatConversationDto>.Failed($"حدث خطأ أثناء إنشاء المحادثة: {ex.Message}");
            }
        }
    }
}
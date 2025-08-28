using System.Threading;
using System.Threading.Tasks;
using MediatR;
using AutoMapper;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Queries.Chat;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Interfaces.Services; // Added for ICurrentUserService

namespace YemenBooking.Application.Handlers.Queries.Chat
{
    /// <summary>
    /// معالج استعلام جلب المحادثات الخاصة بالمستخدم
    /// </summary>
    public class GetConversationsByParticipantQueryHandler : IRequestHandler<GetConversationsByParticipantQuery, PaginatedResult<ChatConversationDto>>
    {
        private readonly IChatConversationRepository _conversationRepo;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly ILogger<GetConversationsByParticipantQueryHandler> _logger;

        public GetConversationsByParticipantQueryHandler(
            IChatConversationRepository conversationRepo,
            ICurrentUserService currentUserService,
            IMapper mapper,
            ILogger<GetConversationsByParticipantQueryHandler> logger)
        {
            _conversationRepo = conversationRepo;
            _currentUserService = currentUserService;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<PaginatedResult<ChatConversationDto>> Handle(GetConversationsByParticipantQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("جلب المحادثات للمستخدم {UserId}", _currentUserService.UserId);
            var userId = _currentUserService.UserId;
            var (items, total) = await _conversationRepo.GetConversationsByParticipantAsync(userId, request.PageNumber, request.PageSize, cancellationToken);
            var dtos = _mapper.Map<IEnumerable<ChatConversationDto>>(items);
            return PaginatedResult<ChatConversationDto>.Create(dtos, request.PageNumber, request.PageSize, total);
        }
    }
} 
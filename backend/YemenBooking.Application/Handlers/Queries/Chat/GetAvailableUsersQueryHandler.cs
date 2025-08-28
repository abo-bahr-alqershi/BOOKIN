namespace YemenBooking.Application.Handlers.Queries.Chat
{
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading;
    using System.Threading.Tasks;
    using AutoMapper;
    using MediatR;
    using Microsoft.EntityFrameworkCore;
    using YemenBooking.Application.DTOs.Users;
    using YemenBooking.Application.DTOs;
    using YemenBooking.Application.Queries.Chat;
    using YemenBooking.Core.Interfaces.Repositories;

    /// <summary>
    /// معالج استعلام جلب قائمة المستخدمين المتاحين للمحادثة
    /// Handler for GetAvailableUsersQuery
    /// </summary>
    public class GetAvailableUsersQueryHandler : IRequestHandler<GetAvailableUsersQuery, ResultDto<IEnumerable<ChatUserDto>>>
    {
        private readonly IUserRepository _userRepo;
        private readonly IMapper _mapper;

        public GetAvailableUsersQueryHandler(IUserRepository userRepo, IMapper mapper)
        {
            _userRepo = userRepo;
            _mapper = mapper;
        }

        public async Task<ResultDto<IEnumerable<ChatUserDto>>> Handle(GetAvailableUsersQuery request, CancellationToken cancellationToken)
        {
            IQueryable<YemenBooking.Core.Entities.User> query = _userRepo.GetQueryable().AsNoTracking();
            query = query.Include(u => u.UserRoles).ThenInclude(ur => ur.Role);
            query = query.Include(u => u.Properties);

            if (!string.IsNullOrEmpty(request.UserType))
                query = query.Where(u => u.UserRoles.Any(ur => ur.Role != null && ur.Role.Name.ToLower() == request.UserType.ToLower()));

            if (request.PropertyId.HasValue)
                query = query.Where(u => u.Properties.Any(p => p.Id == request.PropertyId));

            var users = await query.ToListAsync(cancellationToken);
            var dtos = _mapper.Map<IEnumerable<ChatUserDto>>(users);

            return ResultDto<IEnumerable<ChatUserDto>>.Ok(dtos);
        }
    }
} 
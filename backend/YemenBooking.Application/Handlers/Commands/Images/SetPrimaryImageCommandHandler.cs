using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Commands.Images;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;

namespace YemenBooking.Application.Handlers.Commands.Images
{
    /// <summary>
    /// معالج أمر تعيين صورة كرئيسية لكيان أو وحدة
    /// Handler for SetPrimaryImageCommand to set an image as main
    /// </summary>
    public class SetPrimaryImageCommandHandler : IRequestHandler<SetPrimaryImageCommand, ResultDto<bool>>
    {
        private readonly IPropertyImageRepository _imageRepository;
        private readonly IUnitOfWork _unitOfWork;

        public SetPrimaryImageCommandHandler(
            IPropertyImageRepository imageRepository,
            IUnitOfWork unitOfWork)
        {
            _imageRepository = imageRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<ResultDto<bool>> Handle(SetPrimaryImageCommand request, CancellationToken cancellationToken)
        {
            var success = false;
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // تحديث حالة الصورة الرئيسية الجديدة
                success = await _imageRepository.UpdateMainImageStatusAsync(request.ImageId, true, cancellationToken);

                // إذا كان مرتبطاً بكيان أو وحدة، تأكد من تمييز الصورة الجديدة فقط
                // Updates handled inside repository or additional logic here
            }, cancellationToken);

            return success
                ? ResultDto<bool>.Ok(true, "تم تعيين الصورة الرئيسية بنجاح")
                : ResultDto<bool>.Failure("فشل في تعيين الصورة الرئيسية");
        }
    }
} 
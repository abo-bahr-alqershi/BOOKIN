using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Commands.Images;
using YemenBooking.Application.DTOs;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Interfaces.Services;
using YemenBooking.Core.Interfaces;

namespace YemenBooking.Application.Handlers.Commands.Images
{
    /// <summary>
    /// معالج أمر حذف صورة واحدة (مؤقت أو دائم)
    /// Handler for DeleteImageCommand to delete a single image (soft or permanent)
    /// </summary>
    public class DeleteImageCommandHandler : IRequestHandler<DeleteImageCommand, ResultDto<bool>>
    {
        private readonly IPropertyImageRepository _imageRepository;
        private readonly IFileStorageService _fileStorageService;
        private readonly IUnitOfWork _unitOfWork;

        public DeleteImageCommandHandler(
            IPropertyImageRepository imageRepository,
            IFileStorageService fileStorageService,
            IUnitOfWork unitOfWork)
        {
            _imageRepository = imageRepository;
            _fileStorageService = fileStorageService;
            _unitOfWork = unitOfWork;
        }

        public async Task<ResultDto<bool>> Handle(DeleteImageCommand request, CancellationToken cancellationToken)
        {
            // جلب الصورة من المستودع
            var image = await _imageRepository.GetPropertyImageByIdAsync(request.ImageId, cancellationToken);
            if (image == null)
                return ResultDto<bool>.Failure("الصورة غير موجودة");

            var success = false;
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // حذف السجل
                success = await _imageRepository.DeletePropertyImageAsync(request.ImageId, cancellationToken);
                // حذف الملف من التخزين إذا كان حذف دائم
                if (success && request.Permanent && !string.IsNullOrEmpty(image.Url))
                {
                    await _fileStorageService.DeleteFileAsync(image.Url, cancellationToken);
                }
            }, cancellationToken);

            return success
                ? ResultDto<bool>.Ok(true, "تم حذف الصورة بنجاح")
                : ResultDto<bool>.Failure("فشل في حذف الصورة");
        }
    }
} 
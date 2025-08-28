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
    /// معالج أمر إعادة ترتيب الصور
    /// Handler for ReorderImagesCommand to update display order of images
    /// </summary>
    public class ReorderImagesCommandHandler : IRequestHandler<ReorderImagesCommand, ResultDto<bool>>
    {
        private readonly IPropertyImageRepository _imageRepository;
        private readonly IUnitOfWork _unitOfWork;

        public ReorderImagesCommandHandler(
            IPropertyImageRepository imageRepository,
            IUnitOfWork unitOfWork)
        {
            _imageRepository = imageRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<ResultDto<bool>> Handle(ReorderImagesCommand request, CancellationToken cancellationToken)
        {
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                foreach (var assignment in request.Assignments)
                {
                    var image = await _imageRepository.GetPropertyImageByIdAsync(assignment.ImageId, cancellationToken);
                    if (image == null) continue;

                    image.DisplayOrder = assignment.DisplayOrder;
                    await _imageRepository.UpdatePropertyImageAsync(image, cancellationToken);
                }
            }, cancellationToken);

            return ResultDto<bool>.Ok(true, "تم إعادة ترتيب الصور بنجاح");
        }
    }
} 
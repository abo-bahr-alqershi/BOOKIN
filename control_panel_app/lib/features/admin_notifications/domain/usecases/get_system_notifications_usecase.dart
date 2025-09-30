import 'package:dartz/dartz.dart';
import '../../repositories/admin_notifications_repository.dart';
import '../../entities/admin_notification.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/models/paginated_result.dart';

class GetSystemAdminNotificationsUseCase {
  final AdminNotificationsRepository repository;
  GetSystemAdminNotificationsUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<AdminNotificationEntity>>> call({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? status,
  }) => repository.getSystem(page: page, pageSize: pageSize, type: type, status: status);
}


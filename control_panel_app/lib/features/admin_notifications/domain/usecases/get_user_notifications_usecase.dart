import 'package:dartz/dartz.dart';
import '../../repositories/admin_notifications_repository.dart';
import '../../entities/admin_notification.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/models/paginated_result.dart';

class GetUserAdminNotificationsUseCase {
  final AdminNotificationsRepository repository;
  GetUserAdminNotificationsUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<AdminNotificationEntity>>> call({
    required String userId,
    int page = 1,
    int pageSize = 20,
    bool? isRead,
  }) => repository.getUser(userId: userId, page: page, pageSize: pageSize, isRead: isRead);
}


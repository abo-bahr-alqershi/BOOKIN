import 'package:dartz/dartz.dart';
import '../../repositories/admin_notifications_repository.dart';
import '../../../../../core/error/failures.dart';

class DeleteAdminNotificationUseCase {
  final AdminNotificationsRepository repository;
  DeleteAdminNotificationUseCase(this.repository);

  Future<Either<Failure, bool>> call(String notificationId) => repository.delete(notificationId);
}


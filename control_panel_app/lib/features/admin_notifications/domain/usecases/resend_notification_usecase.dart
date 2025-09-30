import 'package:dartz/dartz.dart';
import '../../repositories/admin_notifications_repository.dart';
import '../../../../../core/error/failures.dart';

class ResendAdminNotificationUseCase {
  final AdminNotificationsRepository repository;
  ResendAdminNotificationUseCase(this.repository);

  Future<Either<Failure, bool>> call(String notificationId) => repository.resend(notificationId);
}


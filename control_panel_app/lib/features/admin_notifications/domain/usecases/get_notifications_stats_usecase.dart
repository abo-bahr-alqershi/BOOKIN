import 'package:dartz/dartz.dart';
import '../../repositories/admin_notifications_repository.dart';
import '../../../../../core/error/failures.dart';

class GetAdminNotificationsStatsUseCase {
  final AdminNotificationsRepository repository;
  GetAdminNotificationsStatsUseCase(this.repository);

  Future<Either<Failure, Map<String, int>>> call() => repository.getStats();
}


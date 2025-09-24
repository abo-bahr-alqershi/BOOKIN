import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import 'email_verification_event.dart';
import 'email_verification_state.dart';

class EmailVerificationBloc extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  final AuthRepository authRepository;
  EmailVerificationBloc({required this.authRepository}) : super(const EmailVerificationInitial()) {
    on<VerifyEmailSubmitted>(_onVerify);
    on<ResendCodePressed>(_onResend);
  }

  Future<void> _onVerify(VerifyEmailSubmitted event, Emitter<EmailVerificationState> emit) async {
    emit(const EmailVerificationLoading());
    try {
      // Call remote directly via repository's remote datasource pattern is not exposed, use api client via repo helper
      final remote = (authRepository as dynamic).remoteDataSource;
      final ok = await remote.verifyEmail(userId: event.userId, code: event.code);
      if (ok == true) {
        emit(const EmailVerificationSuccess());
      } else {
        emit(const EmailVerificationError('رمز التحقق غير صحيح'));
      }
    } catch (e) {
      emit(EmailVerificationError(e.toString()));
    }
  }

  Future<void> _onResend(ResendCodePressed event, Emitter<EmailVerificationState> emit) async {
    emit(const EmailVerificationLoading());
    try {
      final remote = (authRepository as dynamic).remoteDataSource;
      final retryAfter = await remote.resendEmailVerification(userId: event.userId, email: event.email);
      emit(EmailVerificationCodeResent(retryAfterSeconds: retryAfter));
    } catch (e) {
      emit(EmailVerificationError(e.toString()));
    }
  }
}


part of 'otp_bloc.dart';

abstract class OtpEvent {}

class SubmitOtpEvent extends OtpEvent {
  final String otp;
  final String phoneNumber;
  final bool? isPaypal;
  SubmitOtpEvent(this.otp, this.phoneNumber, this.isPaypal);
}

class ResendOtpEvent extends OtpEvent {}

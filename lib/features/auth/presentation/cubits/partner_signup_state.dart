import 'package:equatable/equatable.dart';

abstract class PartnerSignupState extends Equatable {
  const PartnerSignupState();

  @override
  List<Object?> get props => [];
}

class PartnerSignupInitial extends PartnerSignupState {}

class PartnerSignupLoading extends PartnerSignupState {
  final String? message;
  const PartnerSignupLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class PartnerSignupSuccess extends PartnerSignupState {
  final String message;
  final String userType;

  const PartnerSignupSuccess({required this.message, required this.userType});

  @override
  List<Object?> get props => [message, userType];
}

class PartnerSignupError extends PartnerSignupState {
  final String message;
  const PartnerSignupError(this.message);

  @override
  List<Object?> get props => [message];
}

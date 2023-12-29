import 'package:equatable/equatable.dart';

class CustomFailure extends Equatable {
  const CustomFailure({
    required this.message,
    this.exception,
    this.stackTrace,
  });

  final dynamic exception;
  final dynamic stackTrace;

  final String message;

  @override
  String toString() {
    return '$runtimeType{\n message: $message,\n exception: $exception,\n stackTrace: $stackTrace,\n}';
  }

  @override
  List<Object?> get props => [message, exception, stackTrace];
}

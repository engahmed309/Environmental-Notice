part of 'report_cubit.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportImageSelected extends ReportState {
  final String imagePath;

  ReportImageSelected(this.imagePath);
}

class ReportImageError extends ReportState {
  final String message;

  ReportImageError(this.message);
}

class ReportUpdated extends ReportState {
  final ReportModel report;

  ReportUpdated(this.report);
}

class ReportValidationError extends ReportState {
  final String message;

  ReportValidationError(this.message);
}

class ReportSubmitting extends ReportState {}

class ReportSuccess extends ReportState {
  final String message;

  ReportSuccess(this.message);
}

class ReportError extends ReportState {
  final String message;

  ReportError(this.message);
}

class ReportReset extends ReportState {}

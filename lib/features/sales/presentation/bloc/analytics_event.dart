part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnalyticsEvent extends AnalyticsEvent {
  final DateTime from;
  final DateTime to;

  const LoadAnalyticsEvent({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}

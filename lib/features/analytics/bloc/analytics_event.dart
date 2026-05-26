import '../../../shared/models/transaction.dart';
import 'analytics_state.dart';

sealed class AnalyticsEvent {
  const AnalyticsEvent();
}

final class AnalyticsDataChanged extends AnalyticsEvent {
  const AnalyticsDataChanged(this.transactions);
  final List<Transaction> transactions;
}

final class AnalyticsPeriodChanged extends AnalyticsEvent {
  const AnalyticsPeriodChanged(this.period);
  final AnalyticsPeriod period;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_models.dart';
import 'api_providers.dart';

final analyticsSummaryProvider = FutureProvider<AnalyticsSummaryModel>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getSummary();
});

final hotspotsProvider = FutureProvider<List<HotspotItemModel>>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getHotspots();
});

final recurringIssuesProvider = FutureProvider<List<RecurringIssueModel>>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getRecurringIssues();
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/results_provider.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  final int surveyId;
  final String surveyTitle;

  const ResultsScreen({super.key, required this.surveyId, required this.surveyTitle});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(resultsProvider(widget.surveyId).notifier).loadResults(widget.surveyId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resultsProvider(widget.surveyId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.surveyTitle)),
      body: state.isLoading && state.results == null
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.results == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(resultsProvider(widget.surveyId).notifier).loadResults(widget.surveyId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : state.results == null
                  ? const Center(child: Text('No data'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text('${state.results!.totalResponses}',
                                        style: Theme.of(context).textTheme.headlineLarge),
                                    const Text('Total Responses'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('${state.results!.questionStats.length}',
                                        style: Theme.of(context).textTheme.headlineLarge),
                                    const Text('Questions'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...state.results!.questionStats.map((qs) => _buildQuestionStat(context, qs)),
                      ],
                    ),
    );
  }

  Widget _buildQuestionStat(BuildContext context, qs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(qs.questionText, style: Theme.of(context).textTheme.titleMedium),
            Text('${qs.totalAnswers} answers', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 12),
            if (qs.choiceCounts.isNotEmpty) _buildBarChart(qs),
            if (qs.ratingAvg != null) _buildRatingDisplay(qs),
            if (qs.textAnswers.isNotEmpty) _buildTextAnswers(qs),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(qs) {
    final maxVal = qs.choiceCounts.values.isEmpty ? 1 : qs.choiceCounts.values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: (qs.choiceCounts.length * 35).toDouble().clamp(100, 300),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal.toDouble() + 1,
          barGroups: qs.choiceCounts.entries.toList().asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: Colors.blue,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= qs.choiceCounts.keys.length) return const Text('');
                  final key = qs.choiceCounts.keys.elementAt(idx);
                  return Text(key.length > 6 ? '${key.substring(0, 6)}...' : key,
                      style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildRatingDisplay(qs) {
    return Column(
      children: [
        Text('Average: ${qs.ratingAvg}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: qs.ratingDistribution.entries.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('${e.key}: ${e.value}'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextAnswers(qs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: qs.textAnswers.take(10).map((a) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Text(a),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/local_survey_provider.dart';
import '../../../data/models/local_survey.dart';

class LocalResultsScreen extends ConsumerStatefulWidget {
  final String surveyId;

  const LocalResultsScreen({super.key, required this.surveyId});

  @override
  ConsumerState<LocalResultsScreen> createState() => _LocalResultsScreenState();
}

class _LocalResultsScreenState extends ConsumerState<LocalResultsScreen> {
  LocalSurvey? _survey;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localSurveyRepositoryProvider);
    final survey = await repo.getById(widget.surveyId);
    setState(() {
      _survey = survey;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_survey == null) return const Scaffold(body: Center(child: Text('Survey not found')));

    final survey = _survey!;

    return Scaffold(
      appBar: AppBar(title: Text('Results: ${survey.title}')),
      body: survey.responses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No responses yet', style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                ],
              ),
            )
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
                            Text('${survey.responseCount}',
                                style: Theme.of(context).textTheme.headlineLarge),
                            const Text('Total Responses'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('${survey.questions.length}',
                                style: Theme.of(context).textTheme.headlineLarge),
                            const Text('Questions'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...survey.questions.map((q) {
                  final answers = survey.responses
                      .map((r) => r.answers[q.id])
                      .where((a) => a != null)
                      .toList();
                  final qType = q.questionType.value;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.text, style: Theme.of(context).textTheme.titleMedium),
                          Text('${answers.length} answers', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          const SizedBox(height: 12),
                          if (qType == 'single_choice' || qType == 'multiple_choice')
                            _buildBarChart(answers)
                          else if (qType == 'text')
                            ...answers.map((a) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(a.toString()),
                                ))
                          else if (qType == 'rating' || qType == 'scale')
                            _buildRatingStats(answers),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildBarChart(List<dynamic> answers) {
    final counts = <String, int>{};
    for (final a in answers) {
      if (a is List) {
        for (final v in a) {
          counts[v.toString()] = (counts[v.toString()] ?? 0) + 1;
        }
      } else {
        counts[a.toString()] = (counts[a.toString()] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return const Text('No data');

    final maxVal = counts.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: (counts.length * 40).toDouble().clamp(100, 300),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxVal + 1).toDouble(),
          barGroups: counts.entries.toList().asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: Colors.blue,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= counts.keys.length) return const Text('');
                  final key = counts.keys.elementAt(idx);
                  return Text(key.length > 8 ? '${key.substring(0, 8)}...' : key,
                      style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildRatingStats(List<dynamic> answers) {
    final nums = answers.map((a) => int.tryParse(a.toString())).whereType<int>().toList();
    if (nums.isEmpty) return const Text('No data');

    final avg = nums.reduce((a, b) => a + b) / nums.length;
    final dist = <int, int>{};
    for (final n in nums) {
      dist[n] = (dist[n] ?? 0) + 1;
    }

    return Column(
      children: [
        Text('Average: ${avg.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: dist.entries.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${e.key}: ${e.value}',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
